// Importez la bibliothèque hls.js
import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-radio-player',
  templateUrl: 'radio-player.component.html',
  imports: [ CommonModule ],
  standalone: true,
  styleUrls: ['./radio-player.component.css']
})
export class RadioPlayerComponent {

  @ViewChild('audioPlayer', { static: true }) audioPlayer!: ElementRef<HTMLVideoElement>;
  isPlaying = false;
  currentTime: number = 0;
  duration: number = 0;
  mp3Url: string = 'http://localhost:8287/media/mp3/sortie.mp3';

  constructor() { }

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

  // Fonction qui se déclenche lorsque la musique se termine
  onEnded() {
    this.isPlaying = false;
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