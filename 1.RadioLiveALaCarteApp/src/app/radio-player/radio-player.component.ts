import { Component, ElementRef, ViewChild, Input } from '@angular/core';
import { RadioplayerService } from '../../service/radioplayer.service';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Howl, Howler } from 'howler';
import { NgIf } from '@angular/common';
import { find } from 'rxjs';

@Component({
  selector: 'app-radio-player',
  standalone: true,
  imports: [ NgIf ],
  templateUrl: './radio-player.component.html',
  styleUrls: ['./radio-player.component.css']
})
@Injectable({
  providedIn: 'root',
})

export class RadioPlayerComponent {

  @ViewChild('audioPlayer') audioPlayer!: ElementRef<HTMLAudioElement>;

  isPlaying = false;
  currentTime = 0;  // Temps courant global
  totalDuration = 0;  // Durée totale pour la compilation
  segmentDurations: number[] = [];  // Durées individuelles des segments
  fadeDuration = 2;
  volumeStep = 0.05;
  currentTrackIndex = 0;
  duration = 0;
  isSpeedNormal = true;

  mp3Urls: string[] = [];
  currentAudioIndex: number = 0;

  isLivePlaying: boolean = false;
  mp3UrlsCompilation: string[] = [];
  maxAttempts = 10;
  baseUrl = 'media/mp3/output_20241010_082400_';

  // Initialisation du composant
  constructor(private radioplayerService: RadioplayerService, private http: HttpClient) {
    this.getDailyProgramsNames();
    this.loadLiveMp3Urls();
  }

  private getDailyProgramsNames() {
    this.radioplayerService.getDailyProgramsNames().subscribe({
      next: (data: string[]) => {
        this.mp3Urls = data;
      },
      error: (error) => {
        console.error('Erreur lors de la récupération des données', error);
      }
    });
  }

  loadLiveMp3Urls() {
    
    // Charger les autres fichiers comme compilation
    let attempt = 0;
    let lastSegmentLoadingAttempts = 0;
    const promises: Promise<void>[] = [];

    const loadNext = () => {
      if (attempt >= this.maxAttempts) {
        Promise.all(promises).then(() => {
          if (this.mp3UrlsCompilation.length > 1) {
            this.totalDuration = this.segmentDurations.reduce((acc, duration) => acc + duration, 0);
          }
        });
        return;
      }

      const paddedIndex = String(attempt).padStart(4, '0');
      const url = `${this.baseUrl}${paddedIndex}.mp3`;

      const promise = this.http.head(url, { observe: 'response' }).toPromise()
        .then(response => {
          if (response && response.status === 200) {
            const audio = new Audio(url);
            audio.addEventListener('loadedmetadata', () => {
              const duration = audio.duration;

              this.segmentDurations.push(duration);
              this.mp3UrlsCompilation.push(url);

              attempt++;
              loadNext();
            });
          }
        })
        .catch(error => {
          setTimeout(() => {
            if (lastSegmentLoadingAttempts < 9) {
              loadNext();
              lastSegmentLoadingAttempts++;
            }
          }, 2000);
        });

      promises.push(promise);
    };

    loadNext();
  }

  playPause() {
    const audio = this.audioPlayer.nativeElement;
    const mp3Url = this.getMp3Url();
  
    if (this.isPlaying) {  

      this.isPlaying = false;
      audio.pause();

    } else {  
      this.isPlaying = true;
      
      const audioFileName = audio.src.split('/').pop();
      const mp3FileName = this.getMp3Url().split('/').pop();
  
      if (this.currentAudioIndex > (this.mp3Urls.length)-1) {
        this.isLivePlaying = true;
      }

      // Recharger le fichier si ce n'est pas le bon ou si la lecture est terminée
      if (audio.currentTime === 0 || audioFileName !== mp3FileName) {
        this.loadAndPlayCurrentTrack();
      } else {
        audio.play(); 
      }
    }
  }

  // Mettre à jour manuellement le temps dans la piste actuelle
  seek(event: Event) {
    const input = event.target as HTMLInputElement;
    const globalSeekTime = +input.value;

    // Calculer sur quelle piste on se trouve en fonction du temps global
    let cumulativeDuration = 0;
    for (let i = 0; i < this.segmentDurations.length; i++) {
      cumulativeDuration += this.segmentDurations[i];
      if (globalSeekTime <= cumulativeDuration) {
        this.currentTrackIndex = i;
        const timeInTrack = globalSeekTime - (cumulativeDuration - this.segmentDurations[i]);
        this.audioPlayer.nativeElement.currentTime = timeInTrack;
        this.loadAndPlayCurrentTrack();
        break;
      }
    }
  }

  onTimeUpdate() {
    const audio = this.audioPlayer.nativeElement;
    
    // Calculer le temps global actuel basé sur la piste courante
    let timeInCurrentTrack = audio.currentTime;
    this.currentTime = this.segmentDurations
      .slice(0, this.currentTrackIndex) // Somme des pistes précédentes
      .reduce((acc, duration) => acc + duration, 0) + timeInCurrentTrack; // Ajouter la durée de la piste actuelle
  }

  // Fonction pour charger la compilation après la première piste
  playCompilation() {
    this.isLivePlaying = true;  // Basculer à la compilation
    this.currentAudioIndex = 3331;
    this.currentTrackIndex = 0;  // Index à 1 car la première piste est déjà jouée
    this.totalDuration = this.segmentDurations.reduce((acc, duration) => acc + duration, 0); // Durée totale de la compilation
    this.loadAndPlayCurrentTrack();  // Charger et jouer la première piste de la compilation
  }

  // Recharger la piste actuelle et démarrer la lecture
  // ATTENTION !!! La fonction joue les pistes audios et celles qui constituent le LiveStreaming
  loadAndPlayCurrentTrack() {
    const audio = this.audioPlayer.nativeElement;
    
    // Charger la source
    audio.src = this.getMp3Url();
    audio.load();
  
    // Attendre que les métadonnées (incluant la durée) soient chargées
      audio.addEventListener('loadedmetadata', () => {
        if (this.currentAudioIndex == 0 || this.currentAudioIndex == 1) {
           // La durée de l'audio est maintenant disponible
           console.log(audio.duration);
            this.totalDuration = audio.duration;  // Obtenir la durée et la stocker
            console.log(audio.duration);
        }
       
      });
  
    // Lancer la lecture
    audio.play();
    this.isPlaying = true;
  }

  loadAndPlayCurrentAudio(url: string) {
    const audio = this.audioPlayer.nativeElement;
    
    // Charger la source
    audio.src = url;
    audio.load();
  
    // Attendre que les métadonnées (incluant la durée) soient chargées
   
      audio.addEventListener('loadedmetadata', () => {
        //if (this.currentAudioIndex === 0) {
           // La durée de l'audio est maintenant disponible
            this.totalDuration = audio.duration;  // Obtenir la durée et la stocker
            console.log(audio.duration);
        //}
       
      });
  
    // Lancer la lecture
    audio.play();
    this.isPlaying = true;
  }

  // Vérifier si c'est la dernière piste de la compilation
  isLastTrack(): boolean {
    return this.currentTrackIndex === this.mp3UrlsCompilation.length - 1;
  }

  // Récupérer l'URL de la piste actuelle
  getMp3Url(): string {

    if (this.isLivePlaying) {
      return this.mp3UrlsCompilation[this.currentTrackIndex];
    } else {
      return this.mp3Urls[this.currentAudioIndex];
    }

  }

  // Basculer à la piste suivante manuellement
  nextTrackManual() {
    this.currentAudioIndex++;
    this.isLivePlaying = true;
    this.playCompilation();
  }

  nextTrack() {

    console.log(this.currentAudioIndex);

    if (this.currentAudioIndex < this.mp3Urls.length) {
      this.currentAudioIndex++; // AUDIO est pour les pistes audios séparées les unes des autres
      this.loadAndPlayCurrentAudio('media/mp3/output_0004.mp3');
    }

    /*if (!this.isLastTrack()) {
      this.isLivePlaying = true;
      this.currentTrackIndex++; // TRACK est pour la compilation de segments
      this.loadAndPlayCurrentTrack();
    }*/
  }

  // Gestion de la fin d'une piste
  onEnded() {
    if (this.currentAudioIndex >= (this.mp3Urls.length)-1) {
      this.playCompilation();  // Passer à la compilation après la première piste
    } else {
      this.currentAudioIndex++; // AUDIO est pour les pistes audios séparées les unes des autres
      this.loadAndPlayCurrentTrack();
    }
    
    // Aucune idée de l'utilité de ce bout de code, la compilation est bien lue même sans
    /* else if (!this.isLastTrack()) {
      this.nextTrack();
    }*/
  }

  // Affichage du temps en minutes:secondes
  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return minutes + ':' + (secs < 10 ? '0' + secs : secs);
  }


}
