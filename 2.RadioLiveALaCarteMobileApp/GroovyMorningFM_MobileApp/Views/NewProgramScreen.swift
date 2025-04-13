//
//  ContentView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI

struct NewProgramScreen: View {
    
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @ObservedObject var apiService: APIService = APIService.shared
    
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
            
            HStack {
                Text("Back")
                    .bold()
                    .foregroundStyle(Color.blue)
                    .onTapGesture {
                        if (bigModel.viewHistoryList.count >= 2) {
                            bigModel.currentView = bigModel.viewHistoryList[bigModel.viewHistoryList.count-2]
                        }
                    }
                Spacer()
            }
            
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
                                apiService.searchByName(for: newValue) { listAndAmountOfResponses in
                                    self.listAndAmountOfResponses = listAndAmountOfResponses
                                }
                            }
                        } else {
                            // Effectue l'appel si c'est le premier changement de valeur
                            apiService.searchByName(for: newValue) { listAndAmountOfResponses in
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
                
                Text("Go to the player")
                    .onTapGesture {
                        bigModel.currentView = .MultipleAudiosPlayer
                    }
                
                Button(action: {
                    
                    Task {
                        do {
                            let response = try await APIService.shared.createProgram(
                                radioName: radioName,
                                startTimeHour: hour1,
                                startTimeMinute: minute1,
                                startTimeSeconds: second1,
                                endTimeHour: hour2,
                                endTimeMinute: minute2,
                                endTimeSeconds: second2
                            )
                            print("Réponse du serveur : \(response)")
                            if (ProgramManager.shared.estDansLeFutur(heure: hour1, minute: minute1, seconde: second1) && (radioName != "")) {
                                
                                let calendar = Calendar.current
                                let currentDate = Date()
                                let targetTime = calendar.date(bySettingHour: hour1, minute: minute1, second: second1, of: currentDate)!

                                let timeInterval = targetTime.timeIntervalSince(currentDate)

                                // Si l'heure cible est déjà passée aujourd'hui, ajuste pour demain
                                if timeInterval < 0 {
                                    let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                                    let newTargetTime = calendar.date(bySettingHour: hour1, minute: minute1, second: second1, of: nextDay)!
                                    
                                    RecordingService.shared.startTimer(for: newTargetTime, radioName: radioName.replacingOccurrences(of: " ", with: ""), startTimeHour: hour1, startTimeMinute: minute1, startTimeSeconds: second1, outputName: "test_criveli")
                                } else {
                                    RecordingService.shared.startTimer(for: targetTime, radioName: radioName.replacingOccurrences(of: " ", with: ""), startTimeHour: hour1, startTimeMinute: minute1, startTimeSeconds: second1, outputName: "test_criveli")
                                }
                                
                            } else {
                                print("radio name = \(radioName)")
                                print("Dans le futur")
                            }
                        } catch {
                            print("Erreur : \(error)")
                        }
                    }
                                        
                    if (ProgramManager.shared.estDansLeFutur(heure: hour1, minute: minute1, seconde: second1)) {
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
            
        }.onAppear {
            bigModel.viewHistoryList.append(.NewProgramScreen)
        }
        .padding()
    }
    
}


#Preview {
    NewProgramScreen()
}
