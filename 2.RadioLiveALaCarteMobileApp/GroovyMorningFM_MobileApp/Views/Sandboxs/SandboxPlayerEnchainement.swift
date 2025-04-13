import Foundation
import AVFoundation
import SwiftUI
import FFmpegSupport

class AudioPlayerManagerSandbox: ObservableObject {
    
    private var player: AVPlayer?
    private var audioURLs: [URL] = []
    var currentIndex: Int = 0
        
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
                        
        } catch {
            print("Erreur lors du chargement des fichiers : \(error.localizedDescription)")
        }
    }
    
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
            playCurrentAudio()
            
        } catch {
            print("Erreur lors du chargement des fichiers : \(error.localizedDescription)")
        }
    }
    
    private func playCurrentAudio() {
        guard currentIndex < audioURLs.count else {
            print("Tous les fichiers ont été lus.")
            return
        }

        let currentURL = audioURLs[currentIndex]
        let currentItem = AVPlayerItem(url: currentURL)
        
        // Supprimer les anciennes notifications pour éviter les doublons
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        player = AVPlayer(playerItem: currentItem)
        player?.play()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: currentItem)
    }

    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        currentIndex += 1
        print(currentIndex)
        load()
        playCurrentAudio()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
            }
        }
    
}


