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
  maxAttempts = 10;
  baseUrl = 'media/mp3/output_20241010_082400_';
  
  isFirstTrackPlaying = true;  // Nouvelle variable pour suivre l'état de la première piste

  // Initialisation du composant
  constructor(private radioplayerService: RadioplayerService, private http: HttpClient) {
    this.loadMp3Urls();
  }

  loadMp3Urls() {
    this.mp3Urls.push('media/mp3/output_0004.mp3'); // Ajouter la première piste manuellement
    
    // Charger les autres fichiers comme compilation
    let attempt = 0;
    let lastSegmentLoadingAttempts = 0;
    const promises: Promise<void>[] = [];

    const loadNext = () => {
      if (attempt >= this.maxAttempts) {
        Promise.all(promises).then(() => {
          if (this.mp3Urls.length > 1) {
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
              this.mp3Urls.push(url);

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
  
    if (this.isPlaying) {  
      this.isPlaying = false;
      audio.pause();
    } else {  
      this.isPlaying = true;
      
      const audioFileName = audio.src.split('/').pop();
      const mp3FileName = this.mp3Url.split('/').pop();
  
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

  // Fonction qui joue la première piste et la gestion du timecode pour cette piste
  playFirstTrack() {
    const audio = this.audioPlayer.nativeElement;
    audio.src = 'media/mp3/output_0004.mp3';
    this.totalDuration = 3;  // Supposons que la durée de la première piste est de 3 secondes
    audio.currentTime = 0;
    audio.play();
    this.isPlaying = true;
  }

  // Fonction pour charger la compilation après la première piste
  playCompilation() {
    this.isFirstTrackPlaying = false;  // Basculer à la compilation
    this.currentTrackIndex = 1;  // Index à 1 car la première piste est déjà jouée
    this.totalDuration = this.segmentDurations.reduce((acc, duration) => acc + duration, 0); // Durée totale de la compilation
    this.loadAndPlayCurrentTrack();  // Charger et jouer la première piste de la compilation
  }

  // Recharger la piste actuelle et démarrer la lecture
  loadAndPlayCurrentTrack() {
    const audio = this.audioPlayer.nativeElement;
    audio.src = this.mp3Url;
    audio.load();
    audio.play();
    this.isPlaying = true;
  }

  // Vérifier si c'est la dernière piste de la compilation
  isLastTrack(): boolean {
    return this.currentTrackIndex === this.mp3Urls.length - 1;
  }

  // Récupérer l'URL de la piste actuelle
  get mp3Url(): string {
    return this.mp3Urls[this.currentTrackIndex];
  }

  // Basculer à la piste suivante manuellement
  nextTrackManual() {
    if (this.isFirstTrackPlaying) {
      this.playCompilation();  // Si la première piste est jouée, passer à la compilation
    } else {
      this.nextTrack();
    }
  }

  nextTrack() {
    if (!this.isLastTrack()) {
      this.currentTrackIndex++;
      this.loadAndPlayCurrentTrack();
    }
  }

  // Gestion de la fin d'une piste
  onEnded() {
    this.isPlaying = false;
    if (this.isFirstTrackPlaying) {
      this.playCompilation();  // Passer à la compilation après la première piste
    } else if (!this.isLastTrack()) {
      this.nextTrack();
    }
  }

  // Affichage du temps en minutes:secondes
  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return minutes + ':' + (secs < 10 ? '0' + secs : secs);
  }
}
