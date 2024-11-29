import { Component } from '@angular/core';
import { CommonModule} from "@angular/common";
import {FormControl, FormsModule} from '@angular/forms'; // Import pour ngModel
import { RadioplayerService } from "../service/radioplayer.service";

@Component({
  selector: 'app-radio-search',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './radio-search.component.html',
  styleUrl: './radio-search.component.css'
})
export class RadioSearchComponent {

  searchText: string = '';
  response: string[] = [];

  constructor(private radioplayerService: RadioplayerService) {

  }

  searchByName(radioName: string): void {
    const transformedRadioName = radioName.replace(/\s+/g, '').toLowerCase();
    this.radioplayerService.returnAllNamesFromSearch(transformedRadioName);
    this.response = this.radioplayerService.getAllNamesFromSearch();
  }

}
