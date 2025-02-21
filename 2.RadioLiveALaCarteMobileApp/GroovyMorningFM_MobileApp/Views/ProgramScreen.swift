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
    let imageUrl = URL(string: "https://static2.mytuner.mobi/media/tvos_radios/vhxpjerr5lfa.png")!
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                VStack {
                    
                    HStack {
                        Spacer()
                        Image(systemName: "person.circle")
                            .padding(10)
                    }.background(Color.gray)
                    
                    Text("Bonjour \(userId), voici votre programme du jour")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding(20)
                    
                    List(Array(programs.enumerated()), id: \.element.id) { index, program in
                        HStack {
                            
                            AsyncImage(url: imageUrl){ phase in
                                switch phase {
                                    case .empty:
                                        ProgressView() // Affiche un indicateur de chargement
                                    case .success(let image):
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                    case .failure:
                                        Image(systemName: "photo") // Image de secours en cas d'échec
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 200, height: 200)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                }
                            }
                            
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
                    .onAppear {
                        let fetchedPrograms = APIService.fetchPrograms(for: userId)
                        self.programs = fetchedPrograms
                        bigModel.programs = fetchedPrograms
                    }
                }.edgesIgnoringSafeArea(.all)
                
                VStack {
                    
                    Spacer()
                    
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
                    
                }
                
            }
            
        }
        
    }
}

struct ProgramScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProgramScreen()
    }
}
