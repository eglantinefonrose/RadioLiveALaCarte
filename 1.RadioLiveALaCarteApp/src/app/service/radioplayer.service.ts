import {Injectable} from '@angular/core';
import {RadioStation} from './RadioStationModel';
import {firstValueFrom, Observable, of} from 'rxjs';
import {HttpClient, HttpResponse} from '@angular/common/http';
import {catchError, map} from 'rxjs/operators';
import {User} from './Model/User/User';
import {Program} from './Model/Program/Program';
import {UserHelper} from '../service/Model/User/UserHelper';
import {Router} from '@angular/router';
import {RadioLiveError} from '../service/Model/error/RadioLiveError';
import {RecordName} from "./Model/RecordName/RecordName";
import {BaseURLName} from "./Model/BaseURLName/BaseURLName";
import {RadioNameType} from "./Model/RadioNameModel/RadioNameType";

@Injectable({
  providedIn: 'root',
})

export class RadioplayerService {

  private baseUrl = '/media/mp3';
  errorMessage: string = "";
  inputID: string = "";

  constructor(private http: HttpClient, private router: Router) {}

  // Vérifie si un segment existe
  checkSegmentExists(segmentUrl: string): Observable<boolean> {
    return this.http.head(segmentUrl, { observe: 'response' }).pipe(
      map((response: HttpResponse<Object>) => response.status === 200),
      catchError(() => of(false)) // Renvoie un observable avec `false` en cas d'erreur
    );
  }

  public getDailyProgramsNames(): Observable<string[]> {
    return this.http.get<string[]>('http://localhost:4200/api/radio/getDailyProgramsNames');
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
  /*startRadioRecording(): Promise<any> {
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
  }*/

  public async createProgram(accountId: String): Promise<String> {
    // Make the HTTP call and get an Observable (immediately)
    let resultObservable: Observable<String> = this.http.get<String>(`http://localhost:4200/api/radio/getProgramsByUser/userId/${this.inputID}`);
    return await firstValueFrom(resultObservable);
  }

  // Fonction qui permet de lancer l'enregistrement en segments en utilisant l'API
  public recordProgram(program: Program): Promise<any> {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();

      //    @Path("/recordProgram/programId/{programId}/radioName/{radioName}/startTimeHour/{startTimeHour}/startTimeMinute/{startTimeMinute}/startTimeSeconds/{startTimeSeconds}/endTimeHour/{endTimeHour}/endTimeMinute/{endTimeMinute}/endTimeSeconds/{endTimeSeconds}")
      const fullUrl: string = `api/radio/recordProgram/programId/${program.id}/radioName/${program.radioName}/startTimeHour/${program.startTimeHour}/startTimeMinute/${program.startTimeMinute}/startTimeSeconds/${program.startTimeSeconds}/endTimeHour/${program.endTimeHour}/endTimeMinute/${program.endTimeMinute}/endTimeSeconds/${program.endTimeSeconds}`;

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

  public async fetchAccountData(accountId: String): Promise<User> {
    // Make the HTTP call and get an Observable (immediately)
    let resultObservable: Observable<User> = this.http.get<User>(`http://localhost:4200/api/radio/getUserByID/userID/${accountId}`);

    const userAsJsonObject: User = await firstValueFrom(resultObservable);
    // Perform the jackson-js work manually (because of the "Class declaration must have a name in this context" error we got with JsonParser)
    return UserHelper.build(
      userAsJsonObject.id!,
      userAsJsonObject.firstName!,
      userAsJsonObject.lastName!);
  }


  public async fetchProgramsFromId(accountId: String): Promise<Program[]> {
    // Make the HTTP call and get an Observable (immediately)
    let resultObservable: Observable<Program[]> = this.http.get<Program[]>(`http://localhost:4200/api/radio/getProgramsByUser/userId/${accountId}`);
    return await firstValueFrom(resultObservable);
  }

  public async fetchProgramsFromProgramId(accountId: String): Promise<Program[]> {
    // Make the HTTP call and get an Observable (immediately)
    let resultObservable: Observable<Program[]> = this.http.get<Program[]>(`http://localhost:4200/api/radio/getProgramsByUser/userId/${accountId}`);
    return await firstValueFrom(resultObservable);
  }

  public async getSuitableFileNameByProgramId(programId: String): Promise<RecordName> {
    // Make the HTTP call and get an Observable (immediately)
    let resultObservable: Observable<RecordName> = this.http.get<RecordName>(`http://localhost:4200/api/radio/getSuitableFileNameByProgramId/programId/${programId}`);
    return await firstValueFrom(resultObservable);
  }

  private async getFilesWithoutSegmentNamesList(accountId: String): Promise<string[]> {
    // Make the HTTP call and get an Observable (immediately)
    let resultObservable: Observable<string[]> = this.http.get<string[]>(`http://localhost:4200/api/radio/getFilesWithoutSegmentNamesList/userId/${accountId}`);
    return await firstValueFrom(resultObservable);
  }

  private async getFileWithSegmentBaseURL(accountId: string): Promise<BaseURLName> {

    let resultObservable: Observable<BaseURLName> = this.http.get<BaseURLName>(`http://localhost:4200/api/radio/getFileWithSegmentBaseURL/userId/${accountId}`);
    return await firstValueFrom(resultObservable);

  }

  public login(id: string) {
    // Appeler la méthode du service
      this.fetchAccountData(id).then(
        async (data) => {
          //console.log('Données reçues :', data);
          this.setCurrentUser(data);

          this.fetchProgramsFromId(id).then(
            async (data) => {
              //console.log('Données reçues :', data);

              this.setCurrentUserPrograms(data);

              this.getFilesWithoutSegmentNamesList(id).then(
                async (data) => {
                  this.setProgramUrlList(data);

                  this.getFileWithSegmentBaseURL(id).then(
                    async (data) => {
                      const baseUrlNameValue: string = data.name;
                      this.filesWithSegmentsBaseName = baseUrlNameValue;
                      console.log(`this.filesWithSegmentsBaseName : ${this.filesWithSegmentsBaseName}`);
                      this.router.navigate(['/radioPlayer']);
                    }
                  )

                }
              )
            },
            (error) => {
              console.log(error.error);
              const radioLiveError = error.error as RadioLiveError;
              if ((radioLiveError.prtErrorCode != undefined) && (radioLiveError.prtErrorCode === 'PRT-GNRICBIZNESS-ERR')) {
                console.log(radioLiveError);
                this.errorMessage = "Error : " + radioLiveError.prtUserErrorMessage;
              } else {
                console.log('Unknown technical error:', error);
              }
            }
          );

        },
        (error) => {
          console.log(error.error);
          const radioLiveError = error.error as RadioLiveError;
          if ((radioLiveError.prtErrorCode != undefined) && (radioLiveError.prtErrorCode === 'PRT-GNRICBIZNESS-ERR')) {
            console.log(radioLiveError);
            this.errorMessage = "Error : " + radioLiveError.prtUserErrorMessage;
          } else {
            console.log('Unknown technical error:', error);
          }
        }
      );

  }

  public async searchByName(radioName: string): Promise<RadioStation[]> {

    let resultObservable: Observable<RadioStation[]> = this.http.get<RadioStation[]>(`http://localhost:4200/api/radio/searchByName/${radioName}`);
    return await firstValueFrom(resultObservable);

  }

  private allNamesFromSearch: string[] = [];

  getAllNamesFromSearch(): string[] {
    return this.allNamesFromSearch;
  }

  public returnAllNamesFromSearch(radioName: string): void {

    this.searchByName(radioName).then(
      async (data) => {
        const names: string[] = data.map(radio => radio.name);
        this.allNamesFromSearch = names;
      }
    )

  }

  //
  //
  // USERS
  //
  //

  // CURRENT USER
  private currentUser: User | undefined;
  public setCurrentUser(user: User): void {
    this.currentUser = user;
  }
  public getCurrentUser() {
    return this.currentUser;
  }

  // CURRENT USER PROGRAMS
  private currentUserPrograms: Program[] = [];

  public setCurrentUserPrograms(programs: Program[]) {
    this.currentUserPrograms = programs;
  }

  public getCurrentUserPrograms(): Program[] {
    return this.currentUserPrograms;
  }

  // PROGRAM URL LIST
  private filesWithSegmentsBaseName: string = "";

  public getFilesWithSegmentsBaseName(): string {
    return this.filesWithSegmentsBaseName;
  }

  private programUrlList: string[] = [];

  public setProgramUrlList(programUrlList: string[]) {
    this.programUrlList = programUrlList;
  }

  public getProgramUrlList(): string[] {
    return this.programUrlList;
  }

  //
  //
  // MOCKED
  //
  //

    public getMockedStation(): RadioStation {

      return new RadioStation(
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
          false);

  }

}

