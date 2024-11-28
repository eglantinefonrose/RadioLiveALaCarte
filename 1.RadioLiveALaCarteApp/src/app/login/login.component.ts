import { Component, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { User } from '../service/Model/User/User';
import { Observable } from 'rxjs';
import { firstValueFrom } from 'rxjs';
import { UserHelper } from '../service/Model/User/UserHelper';
import { RadioplayerService } from '../service/radioplayer.service';
import { Router } from '@angular/router';
import { RadioLiveError } from '../service/Model/error/RadioLiveError';
import { FormsModule } from '@angular/forms';
import { Program } from '../service/Model/Program/Program';

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
  inputID: string = "";
  isUserFetchingDone: Boolean = false;
  isProgramsFetchingDone: Boolean = false;

  onInputFocus() {
  }

  public login(id: String) {
    this.radioPlayerService.login(this.inputID);
  }

}
