//
//  FluidPlayerTest.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 09/05/2025.
//

import SwiftUI

struct AudioSegment {
    let url: URL
    let duration: Double
}

import AVFoundation
import Combine

class AudioPlayerManager952025: ObservableObject {
    
    @Published var duration: Double = 0
    @Published var currentTime: Double = 0

    private var player = AVQueuePlayer()
    private var timeObserver: Any?
    private var timer: Timer?

    private var segments: [AudioSegment] = []
    private var itemSegmentMap: [AVPlayerItem: AudioSegment] = [:]
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var filePrefix: String = ""
    
    @Published var isPlaying: Bool = false
    var firstPlay: Bool = true

    init(filePrefix: String) {
        self.filePrefix = filePrefix
        startMonitoring()
        observeTime()
        isPlaying = true
    }

    deinit {
        timer?.invalidate()
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
    }

    private func observeTime() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.updateGlobalCurrentTime()
        }
    }

    private func updateGlobalCurrentTime() {
        guard let currentItem = player.currentItem else { return }

        let currentSegment = itemSegmentMap[currentItem]
        let index = segments.firstIndex { $0.url == currentSegment?.url } ?? 0

        let previousDurations = segments.prefix(index).map { $0.duration }.reduce(0, +)
        let currentItemTime = player.currentTime().seconds

        currentTime = previousDurations + currentItemTime
    }

    func startMonitoring() {
        loadSegments()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.loadSegments()
        }
        player.play()
    }

    private func loadSegments() {
        let files = try? FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
        let newFiles = (files ?? [])
            .filter { $0.lastPathComponent.hasPrefix(filePrefix) && $0.pathExtension == "mp4" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }  // trie par nom

        let alreadyLoadedURLs = Set(segments.map { $0.url })
        let filesToAdd = newFiles.filter { !alreadyLoadedURLs.contains($0) }

        var pendingSegments: [(url: URL, asset: AVURLAsset)] = []

        for fileURL in filesToAdd {
            let asset = AVURLAsset(url: fileURL)
            pendingSegments.append((url: fileURL, asset: asset))
        }

        guard !pendingSegments.isEmpty else { return }

        let group = DispatchGroup()
        var loadedSegments: [AudioSegment] = []

        for (url, asset) in pendingSegments {
            group.enter()
            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                var error: NSError?
                let status = asset.statusOfValue(forKey: "duration", error: &error)
                if status == .loaded {
                    let duration = asset.duration.seconds
                    let segment = AudioSegment(url: url, duration: duration)
                    loadedSegments.append(segment)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let sortedSegments = loadedSegments.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
            for segment in sortedSegments {
                let item = AVPlayerItem(url: segment.url)
                self.player.insert(item, after: nil)
                self.segments.append(segment)
                self.itemSegmentMap[item] = segment
            }
            self.updateTotalDuration()
        }
    }

    private func updateTotalDuration() {
        duration = segments.map { $0.duration }.reduce(0, +)
    }
    
    func seek(to globalTime: Double) {
        guard !segments.isEmpty else { return }

        // Trouver le segment correspondant
        var accumulated = 0.0
        var targetIndex: Int?
        var timeInSegment: Double = 0

        for (index, segment) in segments.enumerated() {
            let nextAccumulated = accumulated + segment.duration
            if globalTime < nextAccumulated {
                targetIndex = index
                timeInSegment = globalTime - accumulated
                break
            }
            accumulated = nextAccumulated
        }

        guard let index = targetIndex else { return }

        // Recréer la file de lecture
        let newPlayer = AVQueuePlayer()
        let remainingSegments = segments[index...]

        for segment in remainingSegments {
            let item = AVPlayerItem(url: segment.url)
            newPlayer.insert(item, after: nil)
            itemSegmentMap[item] = segment
        }

        player.pause()
        player = newPlayer
        observeTime() // Reconnecte le timeObserver

        // Attendre que le player soit prêt avant le seek
        newPlayer.currentItem?.seek(to: CMTime(seconds: timeInSegment, preferredTimescale: 600), completionHandler: { [weak self] _ in
            newPlayer.play()
            self?.player = newPlayer
        })
    }
    
    func togglePlayPause() {
        
        if self.isPlaying {
            player.pause()
            isPlaying = false
            return
        }
        
        if (!self.isPlaying) {
            if (firstPlay) {
                loadSegments()
                firstPlay = false
                isPlaying = true
                return
            } else {
                player.play()
                isPlaying = true
                return
            }
        }
        
    }
    
}

import SwiftUI

struct FluidPlayerTest: View {
    
    let filePrefix: String
    @StateObject private var manager: AudioPlayerManager952025
    @ObservedObject private var bigModel: BigModel = BigModel.shared
    var playing: Bool = true
    
    init(filePrefix: String, playing: Bool) {
        self.filePrefix = filePrefix
        self.playing = playing
        _manager = StateObject(wrappedValue: AudioPlayerManager952025(filePrefix: filePrefix))
    }

    var body: some View {
        
        VStack {
            
            Image(systemName: "house")
                .foregroundStyle(.blue)
                .onTapGesture {
                    bigModel.currentView = .ProgramScreen
                }
            
            AsyncImage(url: URL(string: bigModel.programs[bigModel.currentProgramIndex].favIcoURL)){ result in
                result.image?
                    .resizable()
                    .scaledToFill()
            }
            .frame(width: 100)

            Text("\(formatTime(manager.currentTime)) / \(formatTime(manager.duration))")
                .font(.caption)
            
            Slider(
                value: Binding(
                    get: { manager.currentTime },
                    set: { newVal in
                        manager.seek(to: newVal)
                    }
                ),
                in: 0...manager.duration,
                onEditingChanged: { isEditing in
                    // Optionnel : pause le temps du glissement
                }
            )
            
        }.onChange(of: playing) { oldValue, newValue in
            manager.togglePlayPause()
        }
        .padding()
    }

    private func formatTime(_ seconds: Double) -> String {
        let intSec = Int(seconds)
        let minutes = intSec / 60
        let secs = intSec % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

