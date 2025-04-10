//
//  ContentView.swift
//  Test-FFMPEG
//
//  Created by Eglantine Fonrose on 10/04/2025.
//

import SwiftUI
import AVFoundation
import FFmpegSupport
import Foundation

class AudioPlayer: ObservableObject {
    private var player: AVAudioPlayer?

    init() {
        startSilentAudio()
    }

    private func startSilentAudio() {
        guard let path = Bundle.main.path(forResource: "silent", ofType: "mp3") else {
            print("Silence audio file not found")
            return
        }

        do {
            let url = URL(fileURLWithPath: path)
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop indefinitely
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Error initializing silent audio player: \(error)")
        }
    }
}

struct ContentView: View {
    
    @State private var audioPlayer: AVPlayer?
    @State private var isProcessing = false
    
    @State private var isPlaying = false
    @State private var durationText = "Durée : --:--"
    let fileName = "franceinter_0002.mp3" // Ton fichier enregistré

    var body: some View {
        
        VStack {
            Text("Conversion Video avec FFMPEG")
                .font(.largeTitle)
                .padding()

            if isProcessing {
                ProgressView("Traitement en cours...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Text("Prêt à lancer la conversion.")
                    .padding()
            }
        }
        /*.onAppear {
            // Configurer la minuterie pour 10h31
            let calendar = Calendar.current
            let currentDate = Date()
            let targetTime = calendar.date(bySettingHour: 14, minute: 59, second: 30, of: currentDate)!

            let timeInterval = targetTime.timeIntervalSince(currentDate)

            // Si l'heure cible est déjà passée aujourd'hui, ajuste pour demain
            if timeInterval < 0 {
                let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                let newTargetTime = calendar.date(bySettingHour: 14, minute: 17, second: 0, of: nextDay)!
                startTimer(for: newTargetTime)
            } else {
                startTimer(for: targetTime)
            }
            
            listAppFiles()
            
        }*/
        
        VStack(spacing: 20) {
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
        }
        
    }
    
    func prepareAudio() {
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
        }

    func togglePlayback() {
        guard let player = audioPlayer else { return }

        if isPlaying {
            player.pause()
        } else {
            player.play()
        }

        isPlaying.toggle()
    }

    private func startTimer(for targetTime: Date) {
        let timer = Timer.scheduledTimer(withTimeInterval: targetTime.timeIntervalSinceNow, repeats: false) { _ in
            runFFMPEGCommand()
        }
        RunLoop.current.add(timer, forMode: .common)
    }

    private func runFFMPEGCommand() {
        isProcessing = true

        // Commande FFMPEG à exécuter
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent("franceinter_0002.mp3")

        let ffmpegCommand = [
            "ffmpeg",
            "-i", "http://direct.franceinter.fr/live/franceinter-midfi.mp3",
            "-t", "10",
            "-c", "copy",
            outputURL.path
        ]
        
        ffmpeg(ffmpegCommand)
    }
}

func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
}

func listAppFiles() {
    let documentsURL = getDocumentsDirectory()

    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
        
        if fileURLs.isEmpty {
            print("📁 Aucun fichier trouvé dans Documents.")
        } else {
            print("📁 Fichiers dans Documents:")
            for fileURL in fileURLs {
                print("📄 \(fileURL.lastPathComponent) -> \(fileURL.path)")
            }
        }
    } catch {
        print("❌ Erreur lors de la lecture du dossier Documents: \(error)")
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
