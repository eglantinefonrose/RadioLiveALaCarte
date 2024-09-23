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
  isSpeedNormal = true;  // Par défaut, la vitesse est normale
  mp3Url: string = 'http://localhost:8287/media/mp3/sortie.mp3';

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

  rewindToStart() {
    const audio = this.audioPlayer.nativeElement;
    audio.currentTime = 0;  // Revenir au début
    this.currentTime = 0;  // Mettre à jour l'interface
    if (!audio.paused) {
      audio.play();  // Reprendre la lecture si l'audio est en cours de lecture
    }
  } 
  
  // Méthode pour formater le temps en minutes:secondes
  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return minutes + ':' + (secs < 10 ? '0' + secs : secs);
  }


  // Fonction pour lire en x2 ou revenir à la vitesse normale
  toggleSpeed() {
    const audio = this.audioPlayer.nativeElement;
    if (this.isSpeedNormal) {
      audio.playbackRate = 2;  // Passer à la vitesse x2
    } else {
      audio.playbackRate = 1;  // Revenir à la vitesse normale
    }
    this.isSpeedNormal = !this.isSpeedNormal;  // Basculer l'état
  }

  // Fonction qui se déclenche lorsque la musique se termine
  onEnded() {
    this.isPlaying = false;
    this.audioPlayer.nativeElement.playbackRate = 1;  // Réinitialiser la vitesse normale à la fin
  }

  // Mettre à jour la durée de la musique et le temps actuel
  onTimeUpdate() {
    this.currentTime = this.audioPlayer.nativeElement.currentTime;
    this.duration = this.audioPlayer.nativeElement.duration;
  }

  // Permettre de naviguer dans la musique
  seek(event: Event) {
    const input = event.target as HTMLInputElement;
    this.audioPlayer.nativeElement.currentTime = +input.value;
  }
}
