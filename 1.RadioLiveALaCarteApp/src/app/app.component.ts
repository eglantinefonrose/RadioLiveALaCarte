import { Component, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { RadioplayerService } from '../service/radioplayer.service';
import { RadioPlayerComponent } from './radio-player/radio-player.component';

////curl -s -X GET "http://localhost:8287/api/radio/searchByName/FranceInter"
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, RadioPlayerComponent],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css'],
})
export class AppComponent {
  title = '2.RadioStreamingApp';
  radioData: any;

  private radioService = inject(RadioplayerService);

  constructor() {
    //this.getRadioStreamData();
  }

  getRadioStreamData() {
    const url = '/api/radio/searchByName/FranceInter';
    this.radioService.fetchRadioStream(url).then(
      (data) => {
        this.radioData = data;
        console.log('Données reçues:', data);
      },
      (error) => {
        console.error('Erreur lors de la récupération du flux radio:', error);
      }
    );
  }

  getMockedRadioStation() {
    this.radioService.getMockedStation();
  }

  // mp3.service.ts

  fetchRadioStream(url: string): Promise<any> {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', url, true); // Ouvrir une requête HTTP GET asynchrone

      xhr.onreadystatechange = () => {
        if (xhr.readyState === XMLHttpRequest.DONE) {
          if (xhr.status === 200) {
            // Requête réussie
            resolve(xhr.responseText);
          } else {
            // Requête échouée
            reject(`Erreur: ${xhr.status} - ${xhr.statusText}`);
          }
        }
      };

      xhr.onerror = () => {
        reject('Erreur de connexion réseau.');
      };

      xhr.send(); // Envoyer la requête
    });
  }

}
