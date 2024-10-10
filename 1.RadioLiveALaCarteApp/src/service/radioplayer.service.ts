import { Injectable } from '@angular/core';
import { RadioStation } from './RadioStationModel';
import { Observable, of } from 'rxjs';
import { HttpClient, HttpResponse } from '@angular/common/http';
import { map, catchError } from 'rxjs/operators';
import { HttpClientModule } from '@angular/common/http';

@Injectable({
  providedIn: 'root',
})

export class RadioplayerService {

  private baseUrl = '/media/mp3';

  constructor(private http: HttpClient) {}

  // Vérifie si un segment existe
  checkSegmentExists(segmentUrl: string): Observable<boolean> {
    return this.http.head(segmentUrl, { observe: 'response' }).pipe(
      map((response: HttpResponse<Object>) => response.status === 200),
      catchError(() => of(false)) // Renvoie un observable avec `false` en cas d'erreur
    );
  }

  // Génère l'URL du segment suivant à partir du timestamp et du numéro de segment
  getNextSegmentUrl(segmentIndex: number): string {
    // Assurez-vous que segmentIndex est compris dans une plage correcte
    if (segmentIndex > 9999) {
      console.warn('Le numéro de segment est trop grand ! Réinitialisation à 0.');
      segmentIndex = 0; // Ou autre stratégie de gestion
    }

    //output_20240929_095201_0000.mp3
  
    const paddedIndex = String(segmentIndex).padStart(4, '0');
    console.log(`Generated URL with paddedIndex: ${paddedIndex}`);
    //return `${this.baseUrl}/output_20241009_224900output_${paddedIndex}.mp3`;
    return '${this.baseUrl}/output_0000.mp3'
  }

  // Fonction qui permet de lancer l'enregistrement en segments en utilisant l'API
  startRadioRecording(): Promise<any> {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      const fullUrl: string =  "api/radio/program/startsAt/8/24/0/endsAt/8/25/0/?url=https%3A%2F%2Fstream.radiofrance.fr%2Ffranceinfo%2Ffranceinfo_hifi.m3u8%3Fid%3Dradiofrance"

      xhr.open('POST', fullUrl, true); // Ouvrir une requête HTTP GET asynchrone

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

