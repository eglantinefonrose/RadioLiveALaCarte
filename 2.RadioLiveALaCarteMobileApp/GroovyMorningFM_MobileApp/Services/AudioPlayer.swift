//
//  AudioPlayerManager2.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 06/02/2025.
//

import AVFoundation
import SwiftUI
import Foundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate, ObservableObject {
    private var player: AVAudioPlayer?
    private var queue: [URL] = []
    private var specialURLs: [URL] = []
    private var currentIndex: Int = 0
    private var mergedAudioData: Data?
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1
    
    private var timer: Timer?
    
    func play(urls: [URL], specialUrls: [URL]) {
        queue = urls
        specialURLs = specialUrls
        currentIndex = 0
        processSpecialAudio()
    }
    
    private func processSpecialAudio() {
        let group = DispatchGroup()
        var audioDataArray: [Data?] = Array(repeating: nil, count: specialURLs.count) // Tableau indexé
        
        for (index, url) in specialURLs.enumerated() {
            group.enter()
            fetchAudioData(from: url) { data in
                if let data = data {
                    audioDataArray[index] = data // Stockage à l'index correct
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            let orderedData = audioDataArray.compactMap { $0 } // Supprime les nils, conserve l'ordre
            self.mergedAudioData = self.concatenateAudioData(orderedData)
            self.playCurrentItem()
        }
    }

    
    private func concatenateAudioData(_ dataArray: [Data]) -> Data? {
        return dataArray.reduce(Data(), +) // Concatène les fichiers en un seul
    }
    
    private func playCurrentItem() {
        guard currentIndex < queue.count || mergedAudioData != nil else { return }
        
        if currentIndex == queue.count, let data = mergedAudioData {
            playAudioData(data)
        } else {
            let url = queue[currentIndex]
            fetchAudioData(from: url) { [weak self] data in
                guard let self = self, let data = data else { return }
                DispatchQueue.main.async {
                    self.playAudioData(data)
                }
            }
        }
    }
    
    private func playAudioData(_ data: Data) {
        do {
            player = try AVAudioPlayer(data: data)
            player?.delegate = self
            player?.prepareToPlay()
            duration = player?.duration ?? 1
            currentTime = 0
            player?.play()
            isPlaying = true
            startTimer()
        } catch {
            print("Erreur de lecture: \(error)")
        }
    }
    
    func togglePlayPause() {
        if let player = player {
            if player.isPlaying {
                player.pause()
                isPlaying = false
                stopTimer()
            } else {
                player.play()
                isPlaying = true
                startTimer()
            }
        }
    }
    
    func playNext() {
        if currentIndex < queue.count {
            currentIndex += 1
            playCurrentItem()
        }
    }
    
    func playPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
            playCurrentItem()
        }
    }
    
    func seek(to time: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = time
        currentTime = time
    }
    
    private func fetchAudioData(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur de téléchargement: \(error)")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playNext()
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }
            DispatchQueue.main.async {
                self.currentTime = player.currentTime
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}



