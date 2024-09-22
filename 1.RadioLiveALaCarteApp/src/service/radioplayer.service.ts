import { Injectable } from '@angular/core';
import { RadioStation } from './RadioStationModel';

@Injectable({
  providedIn: 'root',
})
export class RadioplayerService {
  constructor() {}

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

  // Fonction pour faire une requête HTTP GET via XMLHttpRequest
  fetchURL(url: string): Promise<any> {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('GET', url, true);
      xhr.responseType = 'blob'; // On précise qu'on attend un fichier Blob (MP3)

      xhr.onreadystatechange = () => {
        if (xhr.readyState === XMLHttpRequest.DONE) {
          if (xhr.status === 200) {
            resolve(xhr.response); // Résoudre avec la réponse (le fichier MP3 en Blob)
          } else {
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

  // mp3-player.component.ts


  // Fonction pour charger et afficher le MP3
  /*loadMp3(): void {
    const mp3Endpoint = 'http://localhost:8080/api/mp3file'; // Remplace par l'URL correcte
    this.fetchRadioStream(mp3Endpoint).then((response) => {
      const url = URL.createObjectURL(response); // Créer une URL pour le fichier Blob
      this.mp3Url = url; // Stocke cette URL pour la passer dans l'élément audio
    }).catch(error => {
      console.error('Erreur lors du téléchargement du fichier MP3', error);
    });
  }*/


  //
  //
  // MOCKED
  //
  //

    public getMockedStation(): RadioStation {

        const FranceInter: RadioStation = new RadioStation(
            "c19c0fb8-1fb7-44e2-87d0-2a55cbc00b9f",
            "a2a2ff62-d40c-4cdb-92ee-c55349e5c716",
            "4093f47e-1039-443d-a87a-dc884be4ce34",
            "FranceInter",
            "https://stream.radiofrance.fr/franceinter/franceinter_hifi.m3u8?id=radiofrance",
            "https://stream.radiofrance.fr/franceinter/franceinter_hifi.m3u8?id=radiofrance",
            "https://www.radiofrance.fr/franceinter",
            "https://www.radiofrance.fr/dist/favicons/franceinter/favicon.png",
            "",
            "France",
            "FR",
            null ?? '',
            "",
            "",
            "",
            33,
            "2023-10-20 18:20:28",
            "2023-10-20T18:20:28Z",
            "UNKNOWN",
            0,
            1,
            1,
            "2024-09-11 04:49:57",
            "2024-09-11T04:49:57Z",
            "2024-09-11 04:49:57",
            "2024-09-11T04:49:57Z",
            "2024-09-11 04:49:57",
            "2024-09-11T04:49:57Z",
            "2024-09-11 06:24:20",
            "2024-09-11T06:24:20Z",
            11,
            1,
            0,
            48.62128949183814,
            2.4609375000000004,
            false)

        return FranceInter;

  }

}

