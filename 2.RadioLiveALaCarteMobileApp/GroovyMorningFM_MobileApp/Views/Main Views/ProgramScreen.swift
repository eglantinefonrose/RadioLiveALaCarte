//
//  ProgramScreen.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import SwiftUI

import Foundation
import SwiftUI
import AVFoundation

struct ProgramScreen: View {
    
    @State private var programs: [Program] = []
    private let userId = "user001"
    var apiService: APIServiceProtocol = APIService.shared
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var showPopup: Bool = false
    @State var ipAddress: String = ""
    
    @State private var audioPlayer: AVPlayer?
    @State private var isProcessing = false
    
    @State private var isPlaying = false
    @State private var durationText = "Durée : --:--"
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Text("Back")
                    .bold()
                    .foregroundStyle(Color.blue)
                    .padding(10)
                    .onTapGesture {
                        if (bigModel.viewHistoryList.count >= 2) {
                            bigModel.currentView = bigModel.viewHistoryList[bigModel.viewHistoryList.count-2]
                        }
                    }
                
                Spacer()
                Image(systemName: "person.circle")
                    .padding(10)
                Image(systemName: "gear")
                    .padding(10)
                    .onTapGesture {
                        bigModel.currentView = .IpAdressView
                    }
            }.background(Color.gray)
            
            Toggle("Show trimmed audios", isOn: $bigModel.raw)
                .bold()
                .padding(20)
            
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
                        }
                        
                        Spacer()
                        
                        Image(systemName: "trash")
                            .onTapGesture {
                                apiService.deleteProgram(programID: program.id) { result in
                                    switch result {
                                    case .success:
                                        Task {
                                            let fetchedPrograms = await apiService.fetchPrograms(for: userId)
                                            self.programs = fetchedPrograms
                                            bigModel.programs = fetchedPrograms
                                        }
                                    case .failure(let error):
                                        print("Erreur lors de la suppression :", error.localizedDescription)
                                    }
                                }
                            }
                        
                    }.onTapGesture {
                        
                        if (program.isProgramAvailable() || program.isInLive()) {
                            
                            let result = bigModel.verifierValeur(index: index)
                            
                            if (result == 1) {
                                bigModel.currentView = .MultipleAudiosPlayer
                            }
                            
                            if (result == 2) {
                                bigModel.currentView = .LiveAudioPlayer
                            }
                            
                        }
                        
                    }
                }
            }
            
            /*VStack(spacing: 20) {
                Text("🎧 Écouter l'enregistrement")
                    .font(.title2)

                Text(durationText)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Button(action: togglePlayback) {
                    Text(isPlaying ? "⏸ Pause" : "▶️ Play")
                        .font(.title)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .onAppear {
                prepareAudio()
            }*/
            
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
            
        }
        .onChange(of: bigModel.ipAdress) { oldId, newIp in
            //if let newIp != "" {
                Task {
                    let fetchedPrograms = await apiService.fetchPrograms(for: userId)
                    self.programs = fetchedPrograms
                    bigModel.programs = fetchedPrograms
                }
            //}
        }
        .onAppear {
            
            bigModel.viewHistoryList.append(.ProgramScreen)
            
            if bigModel.ipAdress == "" {
                showPopup = true
            } else {
                Task {
                    let fetchedPrograms = await apiService.fetchPrograms(for: userId)
                    self.programs = fetchedPrograms
                    bigModel.programs = fetchedPrograms
                    bigModel.generateUrls()
                }
            }
            
            listAppFiles()
            
        }
        .sheet(isPresented: $showPopup) {
            IpInputView(ipAddress: $ipAddress, isPresented: $showPopup, userId: userId, programs: programs)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
    }
    
    func fetchIconName(radioName: String) -> String {
        let urlString = "http://\(bigModel.ipAdress):8287/api/radio/getFavIcoByRadioName/radioName/\(radioName)"
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
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func listAppFiles() {
        let documentsURL = getDocumentsDirectory()

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey])

            if fileURLs.isEmpty {
                print("📁 Aucun fichier trouvé dans Documents.")
            } else {
                print("📁 Fichiers dans Documents:")
                for fileURL in fileURLs {
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                        let fileSize = resourceValues.fileSize ?? 0
                        print("📄 \(fileURL.lastPathComponent) -> \(fileURL.path) (\(fileSize) octets)")
                    } catch {
                        print("⚠️ Impossible de lire la taille de \(fileURL.lastPathComponent): \(error)")
                    }
                }
            }
        } catch {
            print("❌ Erreur lors de la lecture du dossier Documents: \(error)")
        }
    }

    
    /*func prepareAudio() {
        
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("❌ Fichier non trouvé : \(fileName)")
                return
            }

            let asset = AVAsset(url: fileURL)
            let duration = asset.duration
            let durationInSeconds = CMTimeGetSeconds(duration)

            if durationInSeconds.isFinite {
                let minutes = Int(durationInSeconds) / 60
                let seconds = Int(durationInSeconds) % 60
                durationText = String(format: "Durée : %02d:%02d", minutes, seconds)
            }

            audioPlayer = AVPlayer(url: fileURL)
        }*/

    func togglePlayback() {
        guard let player = audioPlayer else { return }
        
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        
        isPlaying.toggle()
    }
    
}

struct IpInputView: View {
    
    @Binding var ipAddress: String
    @Binding var isPresented: Bool
    var userId: String
    var apiService: APIServiceProtocol = APIService.shared
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @State var programs: [Program]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Entrez l'adresse IP")
                .font(.headline)
            
            TextField("Adresse IP", text: $ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Annuler") {
                    isPresented = false
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Valider") {
                    isPresented = false
                    BigModel.shared.ipAdress = ipAddress
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
    }
}

struct ProgramScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProgramScreen()
    }
}
