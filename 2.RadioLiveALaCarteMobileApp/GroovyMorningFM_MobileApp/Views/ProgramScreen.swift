//
//  ProgramScreen.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI

import Foundation
import SwiftUI

struct ProgramScreen: View {
    
    @State private var programs: [Program] = []
    private let userId = "user001"
    @ObservedObject var apiService: APIService = APIService.shared
    
    var body: some View {
        NavigationView {
            List(programs) { program in
                VStack(alignment: .leading) {
                    Text(program.radioName)
                        .font(.headline)
                    Text("\(program.startTimeHour):\(program.startTimeMinute):\(program.startTimeSeconds) - \(program.endTimeHour):\(program.endTimeMinute):\(program.endTimeSeconds)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }.onTapGesture {
                    APIService.shared.currentView = .AudioPlayerView
                    apiService.currentProgram = program
                }
            }
            .navigationTitle("Programmes")
            .onAppear {
                let fetchedPrograms = APIService.fetchPrograms(for: userId)
                self.programs = fetchedPrograms
            }
        }
    }
}

struct ProgramScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProgramScreen()
    }
}
