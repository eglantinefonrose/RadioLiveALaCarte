import { Component, ElementRef, ViewChild, Input } from '@angular/core';
import { RadioplayerService } from '../../service/radioplayer.service';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Howl, Howler } from 'howler';
import { NgIf } from '@angular/common';
import { find } from 'rxjs';

@Component({
  selector: 'app-sandbox-audio-player',
  standalone: true,
  imports: [],
  templateUrl: './sandbox-audio-player.component.html',
  styleUrl: './sandbox-audio-player.component.css'
})
@Injectable({
  providedIn: 'root',
})

export class SandboxAudioPlayerComponent {
  volume: number = 1; // Volume par défaut à 100%
  currentTime: number = 0; // Position actuelle de lecture
  duration: number = 0; // Durée totale de l'audio

  playAudio(audio: HTMLAudioElement): void {
    audio.play();
  }

  pauseAudio(audio: HTMLAudioElement): void {
    audio.pause();
  }

  changeVolume(event: Event, audio: HTMLAudioElement): void {
    const input = event.target as HTMLInputElement;
    this.volume = parseFloat(input.value);
    audio.volume = this.volume;
  }

  updateProgress(audio: HTMLAudioElement): void {
    this.currentTime = audio.currentTime; // Met à jour la position actuelle
  }

  initializeAudio(audio: HTMLAudioElement): void {
    this.duration = audio.duration; // Définit la durée totale une fois les métadonnées chargées
  }

  seekAudio(event: Event, audio: HTMLAudioElement): void {
    const input = event.target as HTMLInputElement;
    const seekTime = parseFloat(input.value);
    audio.currentTime = seekTime; // Met à jour la position de lecture
    this.currentTime = seekTime; // Met à jour l'état
  }

  goToTime(audio: HTMLAudioElement, time: number): void {
    if (time >= 0 && time <= audio.duration) {
      audio.currentTime = time;
      this.currentTime = time; // Met à jour l'état pour synchroniser l'affichage
    } else {
      console.warn('Le timecode spécifié est hors des limites de la durée audio.');
    }
  }

}
