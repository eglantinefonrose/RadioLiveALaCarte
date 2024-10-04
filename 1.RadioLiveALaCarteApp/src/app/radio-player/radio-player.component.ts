import { Component, ElementRef, ViewChild, Input } from '@angular/core';
import { RadioplayerService } from '../../service/radioplayer.service';
import { Injectable } from '@angular/core';
import { Howl, Howler } from 'howler';

@Component({
  selector: 'app-radio-player',
  standalone: true,
  imports: [],
  templateUrl: './radio-player.component.html',
  styleUrls: ['./radio-player.component.css']
})
@Injectable({
  providedIn: 'root',
})

export class RadioPlayerComponent {

  // CONSTRUCTOR
  constructor(private radioplayerService: RadioplayerService) {
    
  }

  //ngOnInit() {
    //this.setupAudioPlayer();
  //}

  currentTrackIndex: number = 0; // Index de la piste audio en cours
  
  /*@ViewChild('audioPlayer') audioPlayer!: ElementRef<HTMLAudioElement>;

  isPlaying = false;
  currentTime = 0;
  duration = 0;
  isSpeedNormal = true;

  // Nombre maximum de fichiers audio
  maxFiles: number = 1000; // Ajustez ceci si vous avez plus de 1000 fichiers

  // Liste des URLs des fichiers MP3
  mp3Urls: string[] = [
    'media/mp3/output_20240929_095201_0000.mp3',
    'media/mp3/output_20240929_095201_0001.mp3'
  ];

  //
  //
  //
  // PLAYER PRINCIPAL, PERMETTANT D'ÉCOUTER DIFFÉRENTES PISTES AUDIOS
  //
  //
  //

  // Récupérer l'URL de la piste actuelle
  get mp3Url(): string {
    return this.mp3Urls[this.currentTrackIndex];
  }

  // Vérifier si l'on est sur la première piste
  isFirstTrack(): boolean {
    return this.currentTrackIndex === 0;
  }

  // Vérifier si l'on est sur la dernière piste
  isLastTrack(): boolean {
    return this.currentTrackIndex === this.mp3Urls.length - 1;
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
    // Passer à la piste suivante automatiquement si ce n'est pas la dernière piste
    if (!this.isLastTrack()) {
      this.nextTrack();
      this.loadAndPlayCurrentTrack();
    }
  }

  // Passer à la piste suivante (désactivé si on est à la dernière piste)
  nextTrack() {
    if (!this.isLastTrack()) {
      this.currentTrackIndex++;
      this.loadAndPlayCurrentTrack();
      this.isPlaying = true;
    }
  }

  // Revenir à la piste précédente (désactivé si on est à la première piste)
  previousTrack() {
    const audio = this.audioPlayer.nativeElement;

    // Si on est à plus de 2 secondes sur la piste actuelle, on revient au début
    if (this.isFirstTrack() || (!this.isFirstTrack() && this.currentTime >= 2))  {
      this.rewindToStart();
    } else if (!this.isFirstTrack()) {
      // Sinon, passer à la piste précédente seulement si ce n'est pas la première piste
      this.currentTrackIndex--;
      this.loadAndPlayCurrentTrack();
    }
  }

  // Charger et jouer la piste actuelle
  loadAndPlayCurrentTrack() {
    const audio = this.audioPlayer.nativeElement;

    // Forcer le rechargement de la nouvelle source
    audio.src = this.mp3Url;  // Modifier explicitement la source audio
    audio.load();  // Recharger le nouvel audio

    // Si l'audio est en lecture, on lance la lecture automatique
    if (this.isPlaying || audio.autoplay) {
      audio.play();
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
  }*/

  

  //
  //
  //
  // DOUBLE PLAYERS
  //
  //
  //

  /*@ViewChild('audioPlayer1', { static: true }) audioPlayer1!: ElementRef<HTMLAudioElement>;
  @ViewChild('audioPlayer2', { static: true }) audioPlayer2!: ElementRef<HTMLAudioElement>;

  // Nombre maximum de fichiers audio
  fadeDuration: number = 1000; // Durée du fondu en millisecondes

  setupAudioPlayers(): void {
    const audio1 = this.audioPlayer1.nativeElement;
    const audio2 = this.audioPlayer2.nativeElement;

    // Charger les fichiers audio pour les deux premiers joueurs
    this.loadAudioFiles(audio1, audio2);

    // Ajouter un écouteur pour détecter le temps restant et commencer le fondu enchaîné
    audio1.addEventListener('timeupdate', () => {
      const timeLeft = audio1.duration - audio1.currentTime;

      if (timeLeft <= 1 && audio2.paused) {
        // Lancer le fondu enchaîné
        this.crossfade(audio1, audio2);
      }
    });
  }

  loadAudioFiles(audio1: HTMLAudioElement, audio2: HTMLAudioElement): void {
    const track1 = this.getTrackUrl(this.currentTrackIndex);
    const track2 = this.getTrackUrl(this.currentTrackIndex + 1);

    audio1.src = track1;
    audio2.src = track2;

    // Démarrer la première piste audio
    this.playAudio(audio1);
  }

  getTrackUrl(index: number): string {
    const formattedIndex = String(index).padStart(4, '0'); // Formatage de l'index avec des zéros
    return `media/mp3/output_20240929_095201_${formattedIndex}.mp3`;
  }

  // Méthode pour jouer un fichier audio avec gestion de la promesse
  async playAudio(audio: HTMLAudioElement): Promise<void> {
    try {
      await audio.play();
    } catch (error) {
      console.error('Erreur lors de la lecture du fichier audio :', error);
    }
  }

  // Méthode pour gérer le fondu enchaîné entre deux fichiers audio
  crossfade(audio1: HTMLAudioElement, audio2: HTMLAudioElement): void {
    const fadeStep = 0.05; // Pas de changement de volume
    const fadeInterval = 50; // Intervalle en millisecondes entre chaque changement de volume

    // Jouer le deuxième fichier audio
    this.currentTrackIndex += 1; // Passer à la piste suivante
    this.loadAudioFiles(audio1, audio2); // Charger les nouvelles pistes

    // Démarrer le fondu enchaîné
    const fadeAudio = setInterval(() => {
      if (audio1.volume > 0) {
        audio1.volume = Math.max(0, audio1.volume - fadeStep);
      }
      if (audio2.volume < 1) {
        audio2.volume = Math.min(1, audio2.volume + fadeStep);
      }

      // Si le fondu est terminé, arrêter l'intervalle
      if (audio1.volume === 0 && audio2.volume === 1) {
        clearInterval(fadeAudio);
        audio1.pause(); // Mettre en pause le premier lecteur quand il est complètement fondu
      }
    }, fadeInterval);
  }*/

    baseUrl: string = '/media/mp3/output_';
    currentSegment: number = 0; // initial segment, e.g. 0003
    timestamp: string = '20240929_095201'; // example timestamp
    currentSound: Howl | null = null;
    isPlaying: boolean = false;
    totalDuration: number = 0; // Durée totale en secondes
    currentPosition: number = 0; // Position actuelle en secondes
    updateInterval: any;
  
    //constructor() {}
  
    ngOnInit(): void {
      //this.playSegment(this.currentSegment);
    }

    // Vérifier si Howler.ctx est initialisé avant de reprendre l'audio
    // Méthode appelée lors du clic sur "Play"
  togglePlayPause() {
    if (this.currentSound) {
      if (this.isPlaying) {
        // Si le son est en cours de lecture, on met en pause
        this.currentSound.pause();
        this.isPlaying = false;
        clearInterval(this.updateInterval); // Stopper la mise à jour du slider
      } else {
        // Si le son est en pause, on reprend la lecture
        this.currentSound.play();
        this.isPlaying = true;
        this.updateSlider(); // Reprendre la mise à jour du slider
      }
    } else {
      // Si c'est la première fois, on démarre l'audio
      this.startAudio();
    }
  }

  startAudio() {
    this.playSegment(this.currentSegment);
  }

  playSegment(segmentNumber: number) {
    const url = `${this.baseUrl}${this.timestamp}_${this.formatSegmentNumber(segmentNumber)}.mp3`;

    this.currentSound = new Howl({
      src: [url],
      html5: true,
      volume: 1.0,
      onplay: () => {
        this.isPlaying = true;
        this.totalDuration = this.currentSound?.duration() || 0;
        this.updateSlider();
      },
      onend: () => {
        // Passer au segment suivant après la fin du segment courant
        this.currentSegment++;
        this.playSegment(this.currentSegment);
      },
      onloaderror: (id, err) => {
        console.error('Error loading segment:', err);
      }
    });

    this.currentSound.play();
  }

  // Méthode pour déplacer la position de lecture à partir du slider
  seekTo(event: any) {
    const newTime = event.target.value;
    if (this.currentSound) {
      this.currentSound.seek(newTime); // Déplace la position de lecture
      this.currentPosition = newTime;
    }
  }

  // Mettre à jour le slider pendant que l'audio joue
  updateSlider() {
    this.updateInterval = setInterval(() => {
      if (this.currentSound && this.isPlaying) {
        this.currentPosition = this.currentSound.seek() as number;
      }
    }, 1000);
  }

  // Formater le temps en minutes:secondes
  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs < 10 ? '0' : ''}${secs}`;
  }

  formatSegmentNumber(segmentNumber: number): string {
    return segmentNumber.toString().padStart(4, '0');
  }

}