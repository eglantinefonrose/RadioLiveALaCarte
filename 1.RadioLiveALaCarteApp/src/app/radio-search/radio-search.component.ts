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
  selectedRadioName: string = '';
  selectedStartTime: { hours: number; minutes: number; seconds: number } | null = null;
  selectedEndTime: { hours: number; minutes: number; seconds: number } | null = null;

  constructor(private radioplayerService: RadioplayerService) {

  }

  searchByName(radioName: string): void {

    const transformedRadioName = radioName.replace(/\s+/g, '').toLowerCase();

    this.radioplayerService.searchByName(transformedRadioName).then(
      async (data) => {
        const names: string[] = data.map(radio => radio.name);
        this.response = names;
      }
    )

  }

  setToZero() {
    console.log('Champ vide, réinitialisation');
    this.response = [];
  }

  onInputChange(value: string) {
    if (value.trim() === '') {
      this.setToZero();
    }
  }

  onNameClick(name: string): void {
    this.selectedRadioName = name; // Mettre à jour l'état du nom sélectionné
  }

  onStartTimeChange(event: Event): void {
    const input = (event.target as HTMLInputElement).value;

    if (input) {
      const [hours, minutes, seconds] = input.split(':').map(Number);
      this.selectedStartTime = { hours, minutes, seconds: seconds || 0 }; // Si secondes non fournies, 0 par défaut
    } else {
      this.selectedStartTime = null;
    }
  }

  onEndTimeChange(event: Event): void {
    const input = (event.target as HTMLInputElement).value;

    if (input) {
      const [hours, minutes, seconds] = input.split(':').map(Number);
      this.selectedEndTime = { hours, minutes, seconds: seconds || 0 }; // Si secondes non fournies, 0 par défaut
    } else {
      this.selectedEndTime = null;
    }
  }

  createProgramAndRecord(): void {

    if (this.selectedStartTime && this.selectedEndTime) {
      this.radioplayerService.createProgramAndRecord(this.selectedRadioName, this.selectedStartTime!.hours.toString(), this.selectedStartTime!.minutes.toString(), this.selectedEndTime!.seconds.toString(), this.selectedEndTime!.hours.toString(), this.selectedEndTime!.minutes.toString(), this.selectedEndTime!.seconds.toString(), this.radioplayerService.connectedUserID);
    } else {
      console.log('Aucune heure sélectionnée.');
    }

  }

}
