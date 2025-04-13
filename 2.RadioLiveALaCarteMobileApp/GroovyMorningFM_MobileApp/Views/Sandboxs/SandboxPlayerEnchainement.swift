import Foundation
import SwiftUI
import FFmpegSupport
import AVFoundation
import Combine

class AudioPlayerManagerSandbox: ObservableObject {
    private var player: AVPlayer?
    private var audioURLs: [URL] = []
    private var durations: [Double] = []
    private var currentIndex: Int = 0
    private var timeObserverToken: Any?

    @Published var progress: Double = 0.0
    @Published var currentTime: Double = 0.0
    @Published var totalDuration: Double = 0.0
    
    private var timeObserverPlayer: AVPlayer?

    func loadAndPlay() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Impossible d'accéder au dossier Documents")
            return
        }

        do {
            let allFiles = try FileManager.default.contentsOfDirectory(atPath: documentsURL.path)

            let sortedAudioFiles = allFiles
                .filter { $0.hasPrefix("test_criveli_") && $0.hasSuffix(".mp4") }
                .sorted {
                    let number1 = Int($0.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    let number2 = Int($1.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    return number1 < number2
                }

            audioURLs = sortedAudioFiles.map { documentsURL.appendingPathComponent($0) }
            currentIndex = 0
            durations = Array(repeating: 0.0, count: audioURLs.count)

            // Charger les durées AVANT de jouer (asynchrone)
            preloadDurations { [weak self] in
                self?.totalDuration = self?.durations.reduce(0, +) ?? 0.0
                self?.playCurrentAudio()
            }

        } catch {
            print("Erreur lors du chargement des fichiers : \(error.localizedDescription)")
        }
    }

    private func preloadDurations(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        for (index, url) in audioURLs.enumerated() {
            group.enter()
            let asset = AVAsset(url: url)
            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                var error: NSError?
                let status = asset.statusOfValue(forKey: "duration", error: &error)
                if status == .loaded {
                    let seconds = CMTimeGetSeconds(asset.duration)
                    if seconds.isFinite {
                        self.durations[index] = seconds
                    }
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }

    private func playCurrentAudio() {
        guard currentIndex < audioURLs.count else {
            print("Tous les fichiers ont été lus.")
            return
        }

        let currentURL = audioURLs[currentIndex]
        let currentItem = AVPlayerItem(url: currentURL)

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        player = AVPlayer(playerItem: currentItem)
        player?.play()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: currentItem)

        startTrackingProgress()
    }
    
    /*func loadAndPlay() {
     guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
         print("Impossible d'accéder au dossier Documents")
         return
     }

     do {
         let allFiles = try FileManager.default.contentsOfDirectory(atPath: documentsURL.path)

         let sortedAudioFiles = allFiles
             .filter { $0.hasPrefix("test_criveli_") && $0.hasSuffix(".mp4") }
             .sorted {
                 let number1 = Int($0.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                 let number2 = Int($1.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                 return number1 < number2
             }

         audioURLs = sortedAudioFiles.map { documentsURL.appendingPathComponent($0) }
         currentIndex = 0
         durations = Array(repeating: 0.0, count: audioURLs.count)

         // Charger les durées AVANT de jouer (asynchrone)
         preloadDurations { [weak self] in
             self?.totalDuration = self?.durations.reduce(0, +) ?? 0.0
             self?.playCurrentAudio()
         }

     } catch {
         print("Erreur lors du chargement des fichiers : \(error.localizedDescription)")
     }
 }*/
    
    func load() {
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Impossible d'accéder au dossier Documents")
            return
        }
        
        do {
            let allFiles = try FileManager.default.contentsOfDirectory(atPath: documentsURL.path)

            let sortedAudioFiles = allFiles
                .filter { $0.hasPrefix("test_criveli_") && $0.hasSuffix(".mp4") }
                .sorted {
                    let number1 = Int($0.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    let number2 = Int($1.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    return number1 < number2
                }

            audioURLs = sortedAudioFiles.map { documentsURL.appendingPathComponent($0) }
            durations = Array(repeating: 0.0, count: audioURLs.count)

            // Charger les durées AVANT de jouer (asynchrone)
            preloadDurations { [weak self] in
                self?.totalDuration = self?.durations.reduce(0, +) ?? 0.0
            }
                        
        } catch {
            print("Erreur lors du chargement des fichiers : \(error.localizedDescription)")
        }
        
    }
    
    private func checkForNewFilesAndContinue() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Impossible d'accéder au dossier Documents")
            return
        }

        do {
            let allFiles = try FileManager.default.contentsOfDirectory(atPath: documentsURL.path)

            let sortedAudioFiles = allFiles
                .filter { $0.hasPrefix("test_criveli_") && $0.hasSuffix(".mp4") }
                .sorted {
                    let number1 = Int($0.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    let number2 = Int($1.replacingOccurrences(of: "test_criveli_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    return number1 < number2
                }

            let newAudioURLs = sortedAudioFiles.map { documentsURL.appendingPathComponent($0) }

            // Si on a de nouveaux fichiers
            if newAudioURLs.count > audioURLs.count {
                let addedURLs = Array(newAudioURLs[audioURLs.count..<newAudioURLs.count])
                audioURLs = newAudioURLs

                // Précharger les durées des nouveaux fichiers
                let group = DispatchGroup()
                var newDurations: [Double] = []

                for url in addedURLs {
                    group.enter()
                    let asset = AVAsset(url: url)
                    asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                        var error: NSError?
                        let status = asset.statusOfValue(forKey: "duration", error: &error)
                        if status == .loaded {
                            let seconds = CMTimeGetSeconds(asset.duration)
                            newDurations.append(seconds.isFinite ? seconds : 0)
                        } else {
                            newDurations.append(0)
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) { [weak self] in
                    guard let self = self else { return }
                    self.durations.append(contentsOf: newDurations)
                    self.totalDuration = self.durations.reduce(0, +)
                    self.playCurrentAudio()
                }

            } else {
                // Pas de nouveau fichier → juste continuer
                playCurrentAudio()
            }

        } catch {
            print("Erreur lors de la mise à jour des fichiers : \(error.localizedDescription)")
            playCurrentAudio()
        }
    }

    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        currentIndex += 1
        load()
        checkForNewFilesAndContinue()
    }

    private func startTrackingProgress() {
        // Retirer proprement l'ancien time observer (de son player associé)
        if let token = timeObserverToken, let oldPlayer = timeObserverPlayer {
            oldPlayer.removeTimeObserver(token)
            timeObserverToken = nil
            timeObserverPlayer = nil
        }

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }

            let elapsedInCurrent = CMTimeGetSeconds(time)
            let previousDurations = self.durations.prefix(self.currentIndex).reduce(0, +)
            let totalElapsed = previousDurations + elapsedInCurrent

            self.currentTime = totalElapsed
            if self.totalDuration > 0 {
                self.progress = totalElapsed / self.totalDuration
            }
        }

        // Associer le token à l’instance de player active
        timeObserverPlayer = player
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let token = timeObserverToken, let oldPlayer = timeObserverPlayer {
            oldPlayer.removeTimeObserver(token)
        }
    }

}



struct SandboxPlayerEnchainement: View {
    
    @StateObject private var audioPlayer = AudioPlayerManagerSandbox()
    @State var currentIndex: Int = 0
    
    var body: some View {
        
            VStack {
                
                Text("Lancer l'enregistrement")
                    .onTapGesture {
                        let outputName: String = "test_criveli"
                        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let outputURL = documentsDirectory.appendingPathComponent("\(outputName).mp4")
                        
                        let ffmpegCommand = [
                            "ffmpeg",
                            "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
                            "-t", "50",
                            "-map", "0:a",
                            "-c:a", "aac",
                            "-b:a", "128k",
                            "-f", "tee",
                            "[f=mp4]\(outputURL.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/\(outputName)_%03d.mp4"
                        ]

                        DispatchQueue.global(qos: .userInitiated).async {
                            ffmpeg(ffmpegCommand)
                        }
                    }
                
                Text("Lecteur audio Criveli")
                    .font(.title)
                    .padding()

                Button(action: {
                    audioPlayer.loadAndPlay()
                }) {
                    Text("▶️ Lancer la lecture")
                        .font(.headline)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                ProgressView(value: audioPlayer.progress)
                Text("\(Int(audioPlayer.currentTime)) / \(Int(audioPlayer.totalDuration)) sec")
                
            }
        }
    
}


