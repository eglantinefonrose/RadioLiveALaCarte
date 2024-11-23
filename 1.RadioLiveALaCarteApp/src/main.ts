import { bootstrapApplication, provideProtractorTestingSupport } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { provideHttpClient, withFetch } from '@angular/common/http';
import { provideRouter } from '@angular/router';
import routeConfig from './app/routes';

bootstrapApplication(AppComponent, {
  providers: [
    provideHttpClient(withFetch()),
    provideProtractorTestingSupport(),
    provideRouter(routeConfig)   // Cf https://stackoverflow.com/a/77512684
  ]
}).catch((err) =>
  console.error(err),
);
