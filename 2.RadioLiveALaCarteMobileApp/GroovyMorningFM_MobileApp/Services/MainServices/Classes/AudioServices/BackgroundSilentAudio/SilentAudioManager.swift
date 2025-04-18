//
//  SilentAudioManager.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 10/04/2025.
//

import Foundation
import AVFoundation

class SilentAudioPlayer: ObservableObject, SilentAudioPlayerProtocol {
    private var player: AVAudioPlayer?

    init() {
        startSilentAudio()
    }

    func startSilentAudio() {
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
