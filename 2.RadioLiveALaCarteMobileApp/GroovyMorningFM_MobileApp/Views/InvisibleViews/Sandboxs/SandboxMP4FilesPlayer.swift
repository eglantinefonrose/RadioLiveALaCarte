//
//  SandboxMP4FilesPlayer.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/04/2025.
//

import Foundation
import AVFoundation
import SwiftUI

class SandboxMP4FilesPlayerManager: ObservableObject {
    
    @Published var isPlaying = false
        @Published var currentTrack: String = ""

        private var audioPlayer: AVAudioPlayer?
        private var audioFiles: [URL] = []
        private var currentIndex: Int = 0

        init() {
            loadAudioFiles()
        }

        private func loadAudioFiles() {
            audioFiles.removeAll()

            // 1. Charger depuis le bundle principal
            if let bundleUrls = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) {
                audioFiles.append(contentsOf: bundleUrls)
            }

            // 2. Charger depuis le dossier Documents
            let fileManager = FileManager.default
            if let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                do {
                    let urls = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
                    let audioUrls = urls.filter { $0.pathExtension == "mp3" || $0.pathExtension == "m4a" || $0.pathExtension == "wav" }
                    audioFiles.append(contentsOf: audioUrls)
                } catch {
                    print("Erreur lors du chargement des fichiers dans Documents : \(error)")
                }
            }
        }

        func play(at index: Int) {
            guard index >= 0 && index < audioFiles.count else { return }
            currentIndex = index
            let url = audioFiles[index]
            currentTrack = url.lastPathComponent

            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Erreur lors de la lecture du fichier audio : \(error)")
            }
        }

        func playPause() {
            guard let player = audioPlayer else {
                play(at: currentIndex)
                return
            }

            if player.isPlaying {
                player.pause()
                isPlaying = false
            } else {
                player.play()
                isPlaying = true
            }
        }

        func next() {
            let nextIndex = (currentIndex + 1) % audioFiles.count
            play(at: nextIndex)
        }

        func previous() {
            let prevIndex = (currentIndex - 1 + audioFiles.count) % audioFiles.count
            play(at: prevIndex)
        }

        func getTrackList() -> [String] {
            return audioFiles.map { $0.lastPathComponent }
        }
    
}

struct SandboxMP4FilesPlayerView: View {
    
    @StateObject private var player = SandboxMP4FilesPlayerManager()

    var body: some View {
        
        VStack(spacing: 16) {
                    Text("Lecteur Audio")
                        .font(.title)
                        .bold()

                    List {
                        ForEach(Array(player.getTrackList().enumerated()), id: \.offset) { index, file in
                            Button(action: {
                                player.play(at: index)
                            }) {
                                HStack {
                                    Text(file)
                                    if file == player.currentTrack && player.isPlaying {
                                        Spacer()
                                        Image(systemName: "waveform")
                                    }
                                }
                            }
                        }
                    }

                    if !player.currentTrack.isEmpty {
                        VStack {
                            Text("En lecture :")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(player.currentTrack)
                                .font(.headline)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }

                    HStack {
                        Button(action: { player.previous() }) {
                            Image(systemName: "backward.fill")
                                .font(.largeTitle)
                        }
                        Button(action: { player.playPause() }) {
                            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                                .font(.largeTitle)
                        }
                        Button(action: { player.next() }) {
                            Image(systemName: "forward.fill")
                                .font(.largeTitle)
                        }
                    }
                    .padding()
                }
                .padding()
        
    }
}

