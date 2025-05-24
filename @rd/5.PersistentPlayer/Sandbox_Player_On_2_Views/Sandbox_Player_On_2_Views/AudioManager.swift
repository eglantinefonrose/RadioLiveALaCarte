//
//  AudioManager.swift
//  Sandbox_Player_On_2_Views
//
//  Created by Eglantine Fonrose on 24/05/2025.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    
    static let shared = AudioManager()
    
    var player: AVAudioPlayer?
    @Published var isPlaying = false
    
    private init() {
        prepareAudio()
    }
    
    private func prepareAudio() {
        if let url = Bundle.main.url(forResource: "Edito-politique", withExtension: "m4a") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.prepareToPlay()
            } catch {
                print("Erreur de chargement audio : \(error)")
            }
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func toggle() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
}

