import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { User } from '../service/Model/User';
import { Observable } from 'rxjs';
import { firstValueFrom } from 'rxjs';
import { UserHelper } from '../service/Model/UserHelper';
import { RadioplayerService } from '../service/radioplayer.service';
import { Router } from '@angular/router';
import { RadioLiveError } from '../service/Model/error/RadioLiveError'; 
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {

  constructor(private http: HttpClient, private router: Router) {

  }

  radioPlayerService = inject(RadioplayerService);
  errorMessage: string = "";
  inputID: string = "";

  public async fetchAccountData(accountId: String): Promise<User> {
    // Make the HTTP call and get an Observable (immediately)
    let resultObservable: Observable<User> = this.http.get<User>(`http://localhost:4200/api/radio/getUserByID/userID/${this.inputID}`);

    const userAsJsonObject: User = await firstValueFrom(resultObservable);
    // Perform the jackson-js work manually (because of the "Class declaration must have a name in this context" error we got with JsonParser)
    const resultAsUser: User = UserHelper.build(
      userAsJsonObject.id!,
      userAsJsonObject.firstName!,
      userAsJsonObject.lastName!);
    return resultAsUser;
  }

login(id: String) {
  // Appeler la méthode du service
    this.fetchAccountData(id).then(
      async (data) => {
        console.log('Données reçues :', data);
        this.radioPlayerService.setCurrentUser(data);
        this.router.navigate(['/radioPlayer']);
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

onInputFocus() {
  this.errorMessage = ''; // Set 'wrongLoginPassword' to false when focused
}



}