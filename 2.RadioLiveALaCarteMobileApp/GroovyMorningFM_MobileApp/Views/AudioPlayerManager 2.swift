//
//  AudioPlayerManager.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 11/02/2025.
//

import AVFoundation
import Combine
import FFmpegSupport

// Daniel Morin : 6h56 à 7h

class AudioManagerTest: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    @Published var isPlaying = false
    var numberOfURLs: Int = -1

        private var player: AVAudioPlayer?
        private var updateTimer: Timer?
        private var currentTime: TimeInterval = 0

        private let fileManager = FileManager.default
        private let outputName = "test_criveli"
        private var uuid = UUID().uuidString

        private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        private var outputFile: URL {
            documentsDirectory.appendingPathComponent("concatenated_output_12042025_\(uuid).m4a")
        }

        override init() {
            super.init()
            self.startMonitoring()
        }

        func startMonitoring() {
            concatenateAndPlay()

            // Vérifie toutes les 5 secondes
            updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                self.updateIfNeeded()
            }
        }

        func concatenateAndPlay() {
            currentTime = player?.currentTime ?? 0
            concatenateFiles { [weak self] success in
                guard let self = self, success else { return }
                //DispatchQueue.main.async {
                    self.playAudio()
                //}
            }
        }

        func playAudio() {
            do {
                print("outputFile =")
                print(outputFile)
                self.player = try AVAudioPlayer(contentsOf: outputFile)
                self.player?.currentTime = currentTime
                self.player?.prepareToPlay()
                self.player?.play()
                self.isPlaying = true
            } catch {
                print("Erreur de lecture audio: \(error)")
            }
        }

        func updateIfNeeded() {
            // Pour une version plus fine, tu peux comparer les noms précédents et nouveaux ici.
            concatenateAndPlay()
        }

        func concatenateFiles(completion: @escaping (Bool) -> Void) {
            DispatchQueue.global().async {
                do {
                    
                    let files = try self.fileManager.contentsOfDirectory(at: self.documentsDirectory, includingPropertiesForKeys: nil)
                        .filter { $0.lastPathComponent.hasPrefix("\(self.outputName)_") && $0.pathExtension == "m4a" }
                        .sorted(by: { $0.lastPathComponent < $1.lastPathComponent })

                    guard !files.isEmpty else {
                        print("Aucun fichier à concaténer.")
                        completion(false)
                        return
                    }

                    // Crée un fichier temporaire de liste pour ffmpeg
                    let listFileURL = self.documentsDirectory.appendingPathComponent("ffmpeg_list.txt")
                    let listContent = files.map { "file '\($0.path)'" }.joined(separator: "\n")
                    print("*")
                    print("*")
                    print("LIST CONTENT")
                    print(listContent)
                    print("*")
                    print("*")
                    print("*")
                    try listContent.write(to: listFileURL, atomically: true, encoding: .utf8)

                    let ffmpegCommand = [
                        "ffmpeg",
                        "-f", "concat",
                        "-safe", "0",
                        "-i", listFileURL.path,
                        "-c", "copy",
                        self.outputFile.path
                    ]
                    
                    if (files.count != self.numberOfURLs) {
                        DispatchQueue.global(qos: .userInitiated).async {
                            ffmpeg(ffmpegCommand)
                        }
                    }
                    self.numberOfURLs = files.count
                    completion(true)
                    
                    
                } catch {
                    print("Erreur concaténation: \(error)")
                    completion(false)
                }
            }
        }

        func stop() {
            player?.stop()
            updateTimer?.invalidate()
            isPlaying = false
        }

}
