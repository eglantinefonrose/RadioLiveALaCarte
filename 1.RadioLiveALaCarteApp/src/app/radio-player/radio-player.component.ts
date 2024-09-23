import { Component, ElementRef, ViewChild } from '@angular/core';

@Component({
  selector: 'app-radio-player',
  standalone: true,
  imports: [],
  templateUrl: './radio-player.component.html',
  styleUrls: ['./radio-player.component.css']
})

export class RadioPlayerComponent {
  @ViewChild('audioPlayer') audioPlayer!: ElementRef<HTMLAudioElement>;

  isPlaying = false;
  currentTime = 0;
  duration = 0;
  isSpeedNormal = true;
  currentTrackIndex = 0;

  // Liste des URLs des fichiers MP3
  mp3Urls: string[] = [
    'http://localhost:8287/media/mp3/sortie.mp3',
    'http://localhost:8287/media/mp3/sortie-1550.mp3'
  ];

  // Récupérer l'URL de la piste actuelle
  get mp3Url(): string {
    return this.mp3Urls[this.currentTrackIndex];
  }

  // Démarrer ou mettre en pause la lecture
  playPause() {
    const audio = this.audioPlayer.nativeElement;
    if (audio.paused) {
      audio.play();
      this.isPlaying = true;
    } else {
      audio.pause();
      this.isPlaying = false;
    }
  }

  // Revenir au début de la piste
  rewindToStart() {
    const audio = this.audioPlayer.nativeElement;
    audio.currentTime = 0;
    this.currentTime = 0;
    if (!audio.paused) {
      audio.play();
    }
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

  // Fonction qui se déclenche à la fin de la piste
  onEnded() {
    this.isPlaying = false;
    this.audioPlayer.nativeElement.playbackRate = 1;
    this.isSpeedNormal = true;

    // Passer à la piste suivante automatiquement
    this.nextTrack();
  }

  // Passer à la piste suivante
  nextTrack() {
    if (this.currentTrackIndex < this.mp3Urls.length - 1) {
      this.currentTrackIndex++;
    } else {
      this.currentTrackIndex = 0;  // Revenir à la première piste si on est à la fin
    }

    this.loadAndPlayCurrentTrack();
  }

  // Charger et jouer la piste actuelle
  loadAndPlayCurrentTrack() {
    const audio = this.audioPlayer.nativeElement;

    // Forcer le rechargement de la nouvelle source
    audio.src = this.mp3Url;  // Modifier explicitement la source audio
    audio.load();  // Recharger le nouvel audio

    if (this.isPlaying) {
      audio.play();  // Lire automatiquement si l'audio était déjà en lecture
    }
  }

  // Mettre à jour la durée et le temps actuel
  onTimeUpdate() {
    this.currentTime = this.audioPlayer.nativeElement.currentTime;
    this.duration = this.audioPlayer.nativeElement.duration;
  }

  // Permettre de naviguer dans la musique
  seek(event: Event) {
    const input = event.target as HTMLInputElement;
    this.audioPlayer.nativeElement.currentTime = +input.value;
  }

  // Méthode pour formater le temps en minutes et secondes
  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return minutes + ':' + (secs < 10 ? '0' + secs : secs);
  }
}