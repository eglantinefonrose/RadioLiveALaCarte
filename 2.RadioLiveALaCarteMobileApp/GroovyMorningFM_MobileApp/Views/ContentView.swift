//
//  ContentView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI

struct ContentView: View {
    
    @State private var horaireDebut: Double = 8.0
    @State private var horaireFin: Double = 18.0
    
    var body: some View {
        VStack {
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
        .padding()
    }
}


#Preview {
    ContentView()
}
