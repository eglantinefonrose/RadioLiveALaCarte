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
    @ObservedObject var bigModel: BigModel = BigModel.shared
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Spacer()
                Image(systemName: "person.circle")
                    .padding(10)
            }.background(Color.gray)
            
            Text("Bonjour \(userId), voici votre programme du jour")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(20)
            
            NavigationView {
                
                List(Array(programs.enumerated()), id: \.element.id) { index, program in
                    HStack {
                        AsyncImage(url: URL(string: program.favIcoURL)){ result in
                                    result.image?
                                        .resizable()
                                        .scaledToFill()
                                }
                                .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading) {
                            Text(program.radioName)
                                .font(.headline)
                                .foregroundStyle(program.isProgramAvailable() ? Color.black : Color.gray)
                            Text("\(program.startTimeHour):\(program.startTimeMinute):\(program.startTimeSeconds) - \(program.endTimeHour):\(program.endTimeMinute):\(program.endTimeSeconds)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }.onTapGesture {
                            if (program.isProgramAvailable()) {
                                bigModel.currentProgramIndex = index
                                bigModel.currentView = .AudioPlayerView
                            } else {
                                print("The program isn't available yet")
                            }
                        }
                    }
                }
            }
            
            VStack {
                                
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.white)
                            .fontWeight(.bold)
                        Text("Créer un programme")
                            .foregroundStyle(Color.white)
                    }.padding(.vertical, 20)
                    Spacer()
                }.background(Color.purple)
                .onTapGesture {
                    bigModel.currentView = .NewProgramScreen
                }
                
            }
            
        }.edgesIgnoringSafeArea(.all)
        .onAppear {
            let fetchedPrograms = APIService.fetchPrograms(for: userId)
            self.programs = fetchedPrograms
            bigModel.programs = fetchedPrograms
        }
                    
    }
    
    func fetchIconName(radioName: String) -> String {
        let urlString = "http://localhost:8287/api/radio/getFavIcoByRadioName/radioName/\(radioName)"
        guard let url = URL(string: urlString) else {
            return ""
        }
        
        var resultString: String = ""
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }
            if let error = error {
                print("Erreur :", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? String {
                    resultString = jsonObject
                }
            } catch {
                print("Erreur de décodage :", error.localizedDescription)
            }
        }.resume()
        
        semaphore.wait()
        return resultString
    }
    
}


struct ProgramScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProgramScreen()
    }
}
