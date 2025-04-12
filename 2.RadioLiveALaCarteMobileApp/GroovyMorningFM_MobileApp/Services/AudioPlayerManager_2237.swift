//
//  AudioPlayerManager.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 11/02/2025.
//

import AVFoundation
import Combine

// Daniel Morin : 6h56 à 7h

class AudioPlayerManager_2237: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    private var player: AVAudioPlayer?
        @Published var isPlaying = false
        @Published var currentFileName: String = ""

        func playAudio(named fileName: String) {
            let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
            currentFileName = fileName

            do {
                player = try AVAudioPlayer(contentsOf: fileURL)
                player?.prepareToPlay()
                player?.play()
                isPlaying = true
            } catch {
                print("Erreur de lecture audio : \(error.localizedDescription)")
            }
        }

        func pause() {
            player?.pause()
            isPlaying = false
        }

        func resume() {
            player?.play()
            isPlaying = true
        }

        func stop() {
            player?.stop()
            isPlaying = false
        }

        private func getDocumentsDirectory() -> URL {
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        }
    
}
