import { Component, ElementRef, ViewChild, Input } from '@angular/core';
import { RadioplayerService } from '../../service/radioplayer.service';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Howl, Howler } from 'howler';
import { NgIf } from '@angular/common';

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

  // CONSTRUCTOR
  constructor(private radioplayerService: RadioplayerService, private http: HttpClient) {
    this.loadMp3Urls();
  }

  @ViewChild('audioPlayer') audioPlayer!: ElementRef<HTMLAudioElement>;

  isPlaying = false;
  currentTime = 0;  // Temps courant global
  totalDuration = 0;  // Durée totale des deux pistes (10s + 10s)
  segmentDurations: number[] = [];  // Durées individuelles des segments
  fadeDuration = 2;  // Durée du fondu enchaîné en secondes
  volumeStep = 0.05;  // Étape de diminution/augmentation du volume
  currentTrackIndex = 0;  // L'index du segment actuel
  duration = 0;
  isSpeedNormal = true;
  mp3Urls: string[] = [];
  maxAttempts = 10;  // Nombre maximal de fichiers à tenter de charger
  baseUrl = 'media/mp3/output_20241009_224900output_';

  // Charger les URLs dynamiquement
  loadMp3Urls() {
    let attempt = 0;
    const promises: Promise<void>[] = [];

    // Tenter de charger les fichiers MP3 en vérifiant leur existence
    const loadNext = () => {
        if (attempt >= this.maxAttempts) {
            // Attendre que toutes les tentatives soient complètes avant de démarrer le lecteur
            Promise.all(promises).then(() => {
                if (this.mp3Urls.length > 0) {
                    this.loadAndPlayCurrentTrack();  // Démarrer la lecture si des fichiers existent
                } else {
                    console.error("Aucun fichier MP3 trouvé.");
                }
            });
            return; // Sortir de la fonction
        }

        const paddedIndex = String(attempt).padStart(4, '0');  // Générer un index avec padding 0000, 0001, etc.
        const url = `${this.baseUrl}${paddedIndex}.mp3`;

        // Vérification de l'existence du fichier
        const promise = this.http.head(url, { observe: 'response' }).toPromise()
            .then(response => {
                if (response && response.status === 200) {
                    this.totalDuration += 10;
                    this.segmentDurations.push(10);
                    this.mp3Urls.push(url);
                    attempt++; // Passer à l'index suivant uniquement si le fichier existe
                    loadNext(); // Appeler la fonction récursivement pour le prochain fichier
                } else {
                    // Si le fichier n'existe pas, arrêter la recherche
                    console.log(`Fichier non trouvé: ${url}`);
                    return; // Sortir de la fonction
                }
            });

        promises.push(promise);
    };

    loadNext(); // Démarrer le chargement des fichiers
  }


    // Vérifier si l'on est sur la première piste
  isFirstTrack(): boolean {
    return this.currentTrackIndex === 0;
  }

  // Vérifier si l'on est sur la dernière piste
  isLastTrack(): boolean {
    return this.currentTrackIndex === this.mp3Urls.length - 1;
  }

  // Basculer entre vitesse normale et x2
  toggleSpeed() {
    const audio = this.audioPlayer.nativeElement;
    if (this.isSpeedNormal) {
      audio.playbackRate = 2;  // Lecture en x2
    } else {
      audio.playbackRate = 1;  // Vitesse normale
    }
    this.isSpeedNormal = !this.isSpeedNormal;
  }
  
  // Récupérer l'URL de la piste actuelle
  get mp3Url(): string {
    return this.mp3Urls[this.currentTrackIndex];
  }

  // Fonction pour démarrer ou mettre en pause la lecture
  // Fonction pour démarrer ou mettre en pause la lecture
  playPause() {
    const audio = this.audioPlayer.nativeElement;
  
    if (this.isPlaying) {  // Si la piste est en train d'être jouée
      this.isPlaying = false;
      audio.pause();
    } else {  // Si la piste est en pause
      this.isPlaying = true;
      
      // Comparer uniquement le nom du fichier à la fin de l'URL
      const audioFileName = audio.src.split('/').pop();
      const mp3FileName = this.mp3Url.split('/').pop();
  
      if (audio.currentTime === 0 || audioFileName !== mp3FileName) {
        this.loadAndPlayCurrentTrack();
      } else {
        audio.play();  // Reprendre la lecture là où elle s'était arrêtée
      }
    }
  }

  // Fonction qui se déclenche à la fin de la piste
  onEnded() {
    this.isPlaying = false;
    this.audioPlayer.nativeElement.playbackRate = 1;
    this.isSpeedNormal = true;
    // Passer à la piste suivante automatiquement si ce n'est pas la dernière piste
    if (!this.isLastTrack()) {
      this.nextTrack();
      this.loadAndPlayCurrentTrack();
    }
  }

  // Charger et jouer la piste actuelle avec fondu enchaîné
  loadAndPlayCurrentTrack() {
    const audio = this.audioPlayer.nativeElement;
    
    audio.src = this.mp3Url;  // Charger la source
    audio.load();  // Forcer le rechargement
    
    audio.volume = 1;  // Réinitialiser le volume
    audio.play();

    audio.onended = () => {
      if (!this.isLastTrack()) {
        this.crossfadeNextTrack();
      } else {
        this.isPlaying = false;
      }
    };
  }
  
  // Fonction qui retourne une promesse résolue lorsque 'loadedmetadata' est déclenché
  waitForMetadata(audio: HTMLAudioElement): Promise<void> {
    return new Promise<void>((resolve) => {
      if (audio.readyState >= 1) {
        // Si les métadonnées sont déjà disponibles
        resolve();
      } else {
        // Si elles ne sont pas encore disponibles, on attend l'événement
        audio.addEventListener('loadedmetadata', () => resolve());
      }
    });
  }
  
  // Gestion du fondu enchaîné lors du passage au prochain segment
  crossfadeNextTrack() {
    const audio = this.audioPlayer.nativeElement;
    const fadeOutInterval = setInterval(() => {
      if (audio.volume > 0) {
        audio.volume = Math.max(0, audio.volume - this.volumeStep);
      } else {
        clearInterval(fadeOutInterval);
        this.nextTrack();
        this.crossfadeIn();
      }
    }, this.fadeDuration * 1000 * this.volumeStep);
  }

  crossfadeIn() {
    const audio = this.audioPlayer.nativeElement;
    audio.volume = 0;
    audio.play();

    const fadeInInterval = setInterval(() => {
      if (audio.volume < 1) {
        audio.volume = Math.min(1, audio.volume + this.volumeStep);
      } else {
        clearInterval(fadeInInterval);
      }
    }, this.fadeDuration * 1000 * this.volumeStep);
  }
  
  nextTrack() {
    if (!this.isLastTrack()) {
      //this.loadMp3Urls();
      this.currentTrackIndex++;
      this.loadAndPlayCurrentTrack();
      this.isPlaying = true;
    }
  }

  // Synchronisation du temps global lors de la lecture
  onTimeUpdate() {
    const audio = this.audioPlayer.nativeElement;
    
    // Calculer le temps global actuel basé sur la piste courante
    let timeInCurrentTrack = audio.currentTime;
    this.currentTime = this.segmentDurations
      .slice(0, this.currentTrackIndex) // Somme des pistes précédentes
      .reduce((acc, duration) => acc + duration, 0) + timeInCurrentTrack; // Ajouter la durée de la piste actuelle
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

  // Afficher le temps au format minutes:secondes
  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return minutes + ':' + (secs < 10 ? '0' + secs : secs);
  }

  //
  //
  // LANCER L'ENREGISTREMENT
  //
  //
  
  startRadioRecording() {
    this.radioplayerService.startRadioRecording()
  }

}