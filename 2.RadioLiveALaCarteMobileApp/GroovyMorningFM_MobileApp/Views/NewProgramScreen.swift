//
//  ContentView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI

struct NewProgramScreen: View {
    
    @State private var horaireDebut: Double = 8.0
    @State private var horaireFin: Double = 18.0
    @State private var radioName: String = ""
    @State private var selectedRadioName: String = ""
    @State private var listAndAmountOfResponses: LightenedRadioStationAndAmountOfResponses = LightenedRadioStationAndAmountOfResponses(lightenedRadioStations: [], amountOfResponses: 0)
    
    private let delay: TimeInterval = 0.3
    @State private var lastUpdateTime: Date? = nil
    @FocusState private var isTextFieldFocused: Bool
    
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
            
            //if (isUserTyping) {
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
            //}
            
            if (!isTextFieldFocused) {
            //if (!isUserTyping) {
                
                Text("Sélectionnez les horaires")
                    .font(.title)
                    .padding()
                
                VStack {
                    Text("Début: \(Int(horaireDebut))h")
                    Slider(value: $horaireDebut, in: 0...23, step: 1)
                }
                .padding()
                
                VStack {
                    Text("Fin: \(Int(horaireFin))h")
                    Slider(value: $horaireFin, in: 0...23, step: 1)
                }
                .padding()
                
                Button(action: {
                    APIService.shared.validerHoraire(debut: Int(horaireDebut), fin: Int(horaireFin))
                    print(radioName)
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
}


#Preview {
    NewProgramScreen()
}
