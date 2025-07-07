//
//  ContentView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI
import FFmpegSupport

struct NewProgramScreen: View {
    
    @ObservedObject var bigModel: BigModel = BigModel.shared
    let apiService: APIServiceProtocol = APIService.shared
    let programManager: ProgramManagerProtocol = ProgramManager.shared
    let group = DispatchGroup()
    
    @State private var horaireDebut: Double = 8.0
    @State private var horaireFin: Double = 18.0
    @State private var radioName: String = ""
    @State private var radioUUID: String = ""
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
    
    private let userId = "user001"
    
    var body: some View {
        VStack {
            
            HStack {
                Text("Back")
                    .bold()
                    .foregroundStyle(Color.blue)
                    .onTapGesture {
                        if (bigModel.viewHistoryList.count >= 2) {
                            DispatchQueue.main.async {
                                bigModel.currentView = bigModel.viewHistoryList[bigModel.viewHistoryList.count-2]
                            }
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
                        radioUUID = radioStation.id
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
                        DispatchQueue.main.async {
                            Task {
                                let fetchedPrograms = await apiService.fetchPrograms(for: userId)
                                bigModel.programs = fetchedPrograms
                                bigModel.generateUrls()
                            }
                            bigModel.currentView = .MultipleAudiosPlayer
                        }
                    }
                
                Button(action: {
                    
                    Task {
                        do {
                            
                            if let timestamp = ProgramManager.shared.convertToTimeEpoch(startHour: hour1, startMinute: minute1, startSeconds: second1) {
                                
                                let url = try await APIService.shared.searchURLByUUID(uuid: radioUUID)
                                
                                if let timestampEnd = ProgramManager.shared.convertToTimeEpoch(startHour: hour1, startMinute: minute1, startSeconds: second1) {
                                    
                                    let response = try await APIService.shared.createProgram(
                                        radioName: radioName,
                                        startTime: timestamp,
                                        endTime: timestampEnd,
                                        radioUUID: radioUUID
                                    )
                                    
                                    print("Réponse du serveur : \(response)")
                                    
                                    if (ProgramManager.shared.estDansLeFutur(startTime: timestamp) && (radioName != "")) {
                                        
                                        let delay: Int = timeStringToEpoch(hour: hour2, minute: minute2, second: second2) - timeStringToEpoch(hour: hour1, minute: minute1, second: second1)
                                        let calendar = Calendar.current
                                        let currentDate = Date()
                                        let targetTime1 = calendar.date(bySettingHour: hour1, minute: minute1, second: second1, of: currentDate)!
                                        //let targetTime2 = calendar.date(bySettingHour: hour1, minute: minute1, second: second1+10, of: currentDate)!

                                        let timeInterval = targetTime1.timeIntervalSince(currentDate)

                                        // Si l'heure cible est déjà passée aujourd'hui, ajuste pour demain
                                        if timeInterval < 0 {
                                            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                                            let newTargetTime = calendar.date(bySettingHour: hour1, minute: minute1, second: second1, of: nextDay)!
                                            
                                            RecordingService.shared.startTimer(for: newTargetTime, radioName: radioName.replacingOccurrences(of: " ", with: ""), startTimeHour: hour1, startTimeMinute: minute1, startTimeSeconds: second1, delay: delay, outputName: response, url: url)
                                        }
                                        else {
                                                
                                            RecordingService.shared.startTimer(for: targetTime1, radioName: radioName.replacingOccurrences(of: " ", with: ""), startTimeHour: hour1, startTimeMinute: minute1, startTimeSeconds: second1, delay: delay, outputName: response, url: url)
                                            
                                        }
                                        
                                    } else {
                                        print("radio name = \(radioName)")
                                        print("Dans le futur")
                                    }
                                    
                                }
                                
                            } else {
                                print("Conversion échouée.")
                            }
                            
                        } catch {
                            print("Erreur : \(error)")
                        }
                        
                    }
                    
                    if let timestamp = ProgramManager.shared.convertToTimeEpoch(startHour: hour1, startMinute: minute1, startSeconds: second1) {
                        if (ProgramManager.shared.estDansLeFutur(startTime: timestamp)) {
                            print("L'horaire est déjà passée dans la journée")
                        }
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

func timeStringToEpoch(hour: Int, minute: Int, second: Int) -> Int {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current // Utilise le fuseau horaire local

    // Obtenir la date d'aujourd'hui
    let now = Date()
    let components = calendar.dateComponents([.year, .month, .day], from: now)

    // Créer une date complète avec les heures/minutes/secondes
    var fullComponents = DateComponents()
    fullComponents.year = components.year
    fullComponents.month = components.month
    fullComponents.day = components.day
    fullComponents.hour = hour
    fullComponents.minute = minute
    fullComponents.second = second

    // Convertir en Date, puis en timestamp
    if let date = calendar.date(from: fullComponents) {
        return Int(date.timeIntervalSince1970)
    } else {
        return -1 // Erreur si la date ne peut pas être créée
    }
}



#Preview {
    NewProgramScreen()
}
