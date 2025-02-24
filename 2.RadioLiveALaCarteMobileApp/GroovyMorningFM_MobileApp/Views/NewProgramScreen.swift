//
//  ContentView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI

struct NewProgramScreen: View {
    
    @ObservedObject var bigModel: BigModel = BigModel.shared
    
    @State private var horaireDebut: Double = 8.0
    @State private var horaireFin: Double = 18.0
    @State private var radioName: String = ""
    @State private var selectedRadioName: String = ""
    @State private var listAndAmountOfResponses: LightenedRadioStationAndAmountOfResponses = LightenedRadioStationAndAmountOfResponses(lightenedRadioStations: [], amountOfResponses: 0)
    
    private let delay: TimeInterval = 0.3
    @State private var lastUpdateTime: Date? = nil
    @FocusState private var isTextFieldFocused: Bool
    
    @State private var hour1 = 12
    @State private var minute1 = 0
    @State private var second1 = 0
    
    @State private var hour2 = 12
    @State private var minute2 = 0
    @State private var second2 = 0
    
    let hours = Array(0...23)
    let minutesAndSeconds = Array(0...59)
    
    var body: some View {
        VStack {
            
            Text("Sélectionnez la radio")
                .font(.title)
                .padding()
            
            TextField("Radio name", text: $radioName)
                .focused($isTextFieldFocused)
                .onChange(of: radioName) { oldValue, newValue in
                    
                    if isTextFieldFocused {
                        
                        // Vérifie que le nombre de caractères est supérieur à 3
                        guard newValue.count > 2 else { return }
                        
                        // Vérifie le délai entre les changements de valeur
                        if let lastUpdateTime = lastUpdateTime {
                            let timeInterval = Date().timeIntervalSince(lastUpdateTime)
                            // Si le délai est supérieur à 300 ms, on effectue l'appel API
                            if timeInterval > delay {
                                APIService.searchByName(for: newValue) { listAndAmountOfResponses in
                                    self.listAndAmountOfResponses = listAndAmountOfResponses
                                }
                            }
                        } else {
                            // Effectue l'appel si c'est le premier changement de valeur
                            APIService.searchByName(for: newValue) { listAndAmountOfResponses in
                                self.listAndAmountOfResponses = listAndAmountOfResponses
                            }
                        }
                        
                        // Met à jour le dernier changement de valeur
                        self.lastUpdateTime = Date()
                        
                    }
                    
                }
            
            if isTextFieldFocused {
                
                List(Array(listAndAmountOfResponses.lightenedRadioStations.enumerated()), id: \.element.id) { index, radioStation in
                    HStack {
                        AsyncImage(url: URL(string: radioStation.favicon)){ result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(radioStation.name)
                                .font(.headline)
                        }
                    }.onTapGesture {
                        isTextFieldFocused = false
                        radioName = radioStation.name
                    }
                }
                
            }
            
            if (!isTextFieldFocused) {
                
                VStack {
                    
                    VStack {
                        Text("Premier horaire")
                            .font(.headline)
                        
                        HStack {
                            Picker("Heure", selection: $hour1) {
                                ForEach(hours, id: \.self) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            
                            Picker("Minute", selection: $minute1) {
                                ForEach(minutesAndSeconds, id: \.self) { minute in
                                    Text("\(minute) m").tag(minute)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            
                            Picker("Seconde", selection: $second1) {
                                ForEach(minutesAndSeconds, id: \.self) { second in
                                    Text("\(second) s").tag(second)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    
                    VStack {
                        Text("Deuxième horaire")
                            .font(.headline)
                        
                        HStack {
                            Picker("Heure", selection: $hour2) {
                                ForEach(hours, id: \.self) { hour in
                                    Text("\(hour) h").tag(hour)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            
                            Picker("Minute", selection: $minute2) {
                                ForEach(minutesAndSeconds, id: \.self) { minute in
                                    Text("\(minute) m").tag(minute)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            
                            Picker("Seconde", selection: $second2) {
                                ForEach(minutesAndSeconds, id: \.self) { second in
                                    Text("\(second) s").tag(second)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                        }
                    }
                    
                }
                
                Button(action: {
                    
                    if (estDansLeFutur(heure: hour1, minute: minute1, seconde: second1) && (radioName != "")) {
                        APIService.shared.validerHoraire(radioName: radioName, startTimeHour: hour1, startTimeMinute: minute1, startTimeSeconds: second1, endTimeHour: hour2, endTimeMinute: minute2, endTimeSeconds: second2) { result in
                            
                            switch result {
                                case .success(let message):
                                    print("Succès :", message)
                                    bigModel.currentView = .ProgramScreen
                                case .failure(let error):
                                    print("Erreur :", error.localizedDescription)
                            }
                            
                        }
                    }
                    if !estDansLeFutur(heure: hour1, minute: minute1, seconde: second1) {
                        print("L'horaire est déjà passée dans la journée")
                    }
                    if radioName == "" {
                        print("Le champ de nom de radio est vide")
                    }
                    
                }) {
                    Text("Valider")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            
        }
        .padding()
    }
    
    func estDansLeFutur(heure: Int, minute: Int, seconde: Int) -> Bool {
        let calendrier = Calendar.current
        let maintenant = Date()
        
        var composants = calendrier.dateComponents([.year, .month, .day], from: maintenant)
        composants.hour = heure
        composants.minute = minute
        composants.second = seconde
        
        if let dateDonnee = calendrier.date(from: composants) {
            return dateDonnee > maintenant
        }
        
        return false
    }
    
}


#Preview {
    NewProgramScreen()
}
