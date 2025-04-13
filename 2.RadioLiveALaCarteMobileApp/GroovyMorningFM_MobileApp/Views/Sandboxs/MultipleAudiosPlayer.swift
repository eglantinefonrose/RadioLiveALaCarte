//
//  MultipleAudiosPlayer.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 13/04/2025.
//

import SwiftUI
import AVFoundation
import Combine

class MulitpleAudioPlayerManager: ObservableObject {
    private var player: AVQueuePlayer?
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var isPlaying: Bool = false
    @Published var currentTrackIndex: Int = 0
    private let bigModel: BigModel = BigModel.shared
    
    private let fileNames = ["test_dino.mp4", "miamiam.mp4"]
    private var playerItems: [AVPlayerItem] = []

    init() {
        loadTracksFromDocuments()
        setupPlayer()
    }

    private func loadTracksFromDocuments() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        for fileName in fileNames {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let item = AVPlayerItem(url: fileURL)
                playerItems.append(item)
            } else {
                print("Fichier non trouvé : \(fileURL.lastPathComponent)")
            }
        }
    }

    private func setupPlayer() {
        guard !playerItems.isEmpty else { return }
        player = AVQueuePlayer(items: playerItems)
        observeTime()
        observeTrackEnd()
        updateDuration()
    }

    private func observeTime() {
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }

    private func observeTrackEnd() {
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.currentTrackIndex < self.playerItems.count - 1 {
                    self.currentTrackIndex += 1
                    self.playTrack(at: self.currentTrackIndex)
                } else {
                    self.isPlaying = false
                }
            }
            .store(in: &cancellables)
    }

    private func updateDuration() {
        if let currentItem = player?.currentItem {
            duration = currentItem.asset.duration.seconds
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        updateDuration()
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }

    func playTrack(at index: Int) {
        guard index >= 0 && index < playerItems.count else { return }
        currentTrackIndex = index
        player?.pause()
        player?.removeAllItems()

        for i in index..<playerItems.count {
            player?.insert(playerItems[i], after: nil)
        }

        play()
    }

    func nextTrack() {
        if currentTrackIndex < playerItems.count - 1 {
            playTrack(at: currentTrackIndex + 1)
        } else {
            bigModel.currentView = .TestLivePlayer
        }
    }

    func previousTrack() {
        if currentTime > 3 {
            seek(to: 0)
        } else if currentTrackIndex > 0 {
            playTrack(at: currentTrackIndex - 1)
        }
    }
}

struct MultipleAudiosPlayer: View {
    
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @StateObject private var playerManager = MulitpleAudioPlayerManager()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Piste actuelle : \(playerManager.currentTrackIndex + 1)")
                .font(.title2)

            // Barre de progression
            Slider(value: $playerManager.currentTime, in: 0...playerManager.duration, onEditingChanged: { editing in
                if !editing {
                    playerManager.seek(to: playerManager.currentTime)
                }
            })
            
            Text("\(formatTime(playerManager.currentTime)) / \(formatTime(playerManager.duration))")
                .font(.subheadline)

            // Contrôles
            HStack(spacing: 40) {
                Button(action: {
                    playerManager.previousTrack()
                }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }

                Button(action: {
                    playerManager.togglePlayPause()
                }) {
                    Image(systemName: playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                }

                Button(action: {
                    playerManager.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
        }
        .padding()
        .onAppear {
            playerManager.play()
        }
    }

    func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "0:00" }
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}


