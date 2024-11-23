import { Routes } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { RadioPlayerComponent } from './radio-player/radio-player.component';

const routeConfig: Routes = [
    {
      path: '',
      component: LoginComponent,
      title: 'Login'
    },
    {
        path: 'radioPlayer',
        component: RadioPlayerComponent,
        title: 'Radio Player'
      }
  ];
  
  export default routeConfig;