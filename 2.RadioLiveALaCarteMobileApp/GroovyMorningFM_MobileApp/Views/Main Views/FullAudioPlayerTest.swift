import Foundation
import SwiftUI
import FFmpegSupport
import AVFoundation
import Combine

class FullAudioPlayerTestManager: ObservableObject {
    
    var player: AVPlayer?
    private var audioURLs: [URL] = []
    private var durations: [Double] = []
    private var currentIndex: Int = 0
    private var timeObserverToken: Any?

    @Published var progress: Double = 0.0
    @Published var currentTime: Double = 0.0
    @Published var totalDuration: Double = 0.0
    
    private var timeObserverPlayer: AVPlayer?
    @Published var isPlaying: Bool = false
    var firstPlay: Bool = true
    
    var filePrefix: String
    let filesPrefixs: [String] = BigModel.shared.liveProgramsNames
    
    let bigModel: BigModel = BigModel.shared

    init(filePrefix: String) {
        self.filePrefix = filePrefix
        togglePlayPause()
    }
    
    func loadAndPlay() {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Impossible d'accéder au dossier Documents")
            return
        }

        do {
            let allFiles = try FileManager.default.contentsOfDirectory(atPath: documentsURL.path)
                
                let sortedAudioFiles = allFiles
                    .filter { $0.hasPrefix("\(filePrefix)_") && $0.hasSuffix(".mp4") }
                    .sorted {
                        let number1 = Int($0.replacingOccurrences(of: "\(filePrefix)_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                        let number2 = Int($1.replacingOccurrences(of: "\(filePrefix)_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
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
                
            //}

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
    
    func load() {
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Impossible d'accéder au dossier Documents")
            return
        }
        
        do {
            let allFiles = try FileManager.default.contentsOfDirectory(atPath: documentsURL.path)

            let sortedAudioFiles = allFiles
                .filter { $0.hasPrefix("\(filePrefix)_") && $0.hasSuffix(".mp4") }
                .sorted {
                    let number1 = Int($0.replacingOccurrences(of: "\(filePrefix)_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    let number2 = Int($1.replacingOccurrences(of: "\(filePrefix)_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
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
                .filter { $0.hasPrefix("\(filePrefix)_") && $0.hasSuffix(".mp4") }
                .sorted {
                    let number1 = Int($0.replacingOccurrences(of: "\(filePrefix)_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
                    let number2 = Int($1.replacingOccurrences(of: "\(filePrefix)_", with: "").replacingOccurrences(of: ".mp4", with: "")) ?? 0
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
    
    func seekTo(time targetTime: Double) {
        guard totalDuration > 0, !audioURLs.isEmpty else { return }

        // Trouver le fichier et le temps local dans ce fichier
        var accumulated = 0.0
        var targetIndex = 0

        for (index, duration) in durations.enumerated() {
            if accumulated + duration >= targetTime {
                targetIndex = index
                break
            }
            accumulated += duration
        }

        let seekTimeInFile = targetTime - accumulated
        currentIndex = targetIndex

        let fileURL = audioURLs[targetIndex]
        let item = AVPlayerItem(url: fileURL)

        player?.pause()
        NotificationCenter.default.removeObserver(self)

        player = AVPlayer(playerItem: item)
        player?.seek(to: CMTime(seconds: seekTimeInFile, preferredTimescale: 600)) { [weak self] _ in
            self?.player?.play()
            self?.startTrackingProgress()
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: item)
    }

    func togglePlayPause() {
        
        if self.isPlaying {
            player!.pause()
            isPlaying = false
            return
        }
        
        if (!self.isPlaying) {
            if (firstPlay) {
                loadAndPlay()
                firstPlay = false
                isPlaying = true
                return
            } else {
                player!.play()
                isPlaying = true
                return
            }
        }
        
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let token = timeObserverToken, let oldPlayer = timeObserverPlayer {
            oldPlayer.removeTimeObserver(token)
        }
    }

}



struct FullAudioPlayerTestComponent: View {
    
    let filePrefix: String
    var playing: Bool = true
    @StateObject var manager: MultipleAudiosPlayerManager
    @State private var isDragging = false
    @State private var dragProgress: Double = 0.0
    @ObservedObject var bigModel: BigModel = BigModel.shared
    
    init(filePrefix: String, playing: Bool) {
        self.filePrefix = filePrefix
        self.playing = playing
        _manager = StateObject(wrappedValue: MultipleAudiosPlayerManager(filePrefix: filePrefix))
    }

        var body: some View {
            
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
            
            VStack(spacing: 16) {
                Slider(value: Binding(get: {
                    isDragging ? dragProgress : manager.progress
                }, set: { newValue in
                    isDragging = true
                    dragProgress = newValue
                }), in: 0...1, onEditingChanged: { editing in
                    if !editing {
                        let seekTime = dragProgress * manager.totalDuration
                        manager.seekTo(time: seekTime)
                        isDragging = false
                    }
                })

                Text("\(formatTime(seconds: isDragging ? dragProgress * manager.totalDuration : manager.currentTime)) / \(formatTime(seconds: manager.totalDuration))")

            }
            .padding()
            .onChange(of: playing) { oldValue, newValue in
                manager.togglePlayPause()
            }
            
        }

        func formatTime(seconds: Double) -> String {
            let minutes = Int(seconds) / 60
            let seconds = Int(seconds) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
}


struct FullAudioPlayerTest: View {
    
    let filesPrefixs: [String] = BigModel.shared.liveProgramsNames
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @State var playing: Bool = true
    
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height / 2
    let minHeight: CGFloat = UIScreen.main.bounds.height / 2
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
                
    var body: some View {
        
        ZStack {
            
            VStack {
                
                FluidPlayerTest(filePrefix: "\(filesPrefixs[bigModel.currentProgramIndex])_", playing: playing)
                    .id(filesPrefixs[bigModel.currentProgramIndex])
                
                HStack {
                    Image(systemName: "backward.fill")
                        .font(.title)
                        .disabled(bigModel.currentProgramIndex == 0) // désactiver si on est au début
                        .onTapGesture {
                            if bigModel.currentProgramIndex > 0 {
                                bigModel.currentProgramIndex -= 1
                            } else {
                                if (bigModel.delayedProgramsNames.count != 0) {
                                    bigModel.currentView = .MultipleAudiosPlayer
                                }
                            }
                        }
                    
                    Button(action: {
                        playing.toggle()
                    }) {
                        Image(systemName: playing ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                    }
                    
                    Button(action: {
                        if bigModel.currentProgramIndex < filesPrefixs.count - 1 {
                            bigModel.currentProgramIndex += 1
                        }
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                    .disabled(bigModel.currentProgramIndex == filesPrefixs.count - 1) // désactiver si on est à la fin
                }
                .padding()
            }
            
            BottomSheetView(offsetY: $offsetY, minHeight: minHeight, maxHeight: maxHeight, programs: bigModel.programs)
            
        }
        
    }
    
}

struct FullAudioPlayerTest_Previews: PreviewProvider {
    static var previews: some View {
        FullAudioPlayerTest()
    }
}


