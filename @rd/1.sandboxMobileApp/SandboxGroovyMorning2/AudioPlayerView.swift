import AVFoundation
import Combine
import SwiftUI

class AudioPlayerManager: NSObject, ObservableObject {
    var player: AVQueuePlayer?
    private var playerItems: [AVPlayerItem] = []
    private var playerTimer: Timer?
    
    @Published var isPlaying: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    
    override init() {
        super.init()
        setupObservers()
    }
    
    func loadPlaylist(from urls: [URL]) {
        playerItems = urls.map { AVPlayerItem(url: $0) }
        player = AVQueuePlayer(items: playerItems)
        
        // Update the duration when the player is ready
        if let firstItem = playerItems.first {
            duration = firstItem.asset.duration.seconds
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
        startTimer()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func nextTrack() {
        player?.advanceToNextItem()
        if player?.currentItem == nil {
            isPlaying = false
            stopTimer()
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(trackDidFinish),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    private func startTimer() {
        playerTimer?.invalidate()
        playerTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateCurrentTime()
        }
    }
    
    private func stopTimer() {
        playerTimer?.invalidate()
        playerTimer = nil
    }
    
    private func updateCurrentTime() {
        guard let currentItem = player?.currentItem else { return }
        currentTime = currentItem.currentTime().seconds
        
        // Update duration if needed
        if duration == 0 {
            duration = currentItem.asset.duration.seconds
        }
    }
    
    @objc private func trackDidFinish(notification: Notification) {
        DispatchQueue.main.async {
            if self.player?.currentItem == nil {
                self.isPlaying = false
                self.stopTimer()
            }
        }
    }
}

struct AudioPlayerView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    var body: some View {
        VStack {
            Text("Lecteur Audio")
                .font(.title)
                .padding()
            
            HStack {
                Button(action: {
                    audioManager.play()
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .padding()
                
                Button(action: {
                    audioManager.nextTrack()
                }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .padding()
            }
            
            // Barre de progression
            VStack {
                HStack {
                    Text("\(formattedTime(audioManager.currentTime))")
                    Slider(value: $audioManager.currentTime, in: 0...audioManager.duration, onEditingChanged: { _ in
                        audioManager.player?.seek(to: CMTime(seconds: audioManager.currentTime, preferredTimescale: 1))
                    })
                    Text("\(formattedTime(audioManager.duration))")
                }
                .padding()
            }
        }
        .onAppear {
            // Charger des fichiers distants
            if let url1 = URL(string: "http://localhost:8287/media/mp3/output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_0000.mp3"),
               let url2 = URL(string: "http://localhost:8287/media/mp3/output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_0001.mp3"),
               let url3 = URL(string: "http://localhost:8287/media/mp3/output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_0002.mp3"){
                audioManager.loadPlaylist(from: [url1, url2, url3])
            }
        }
    }
    
    // Formater le temps en format mm:ss
    private func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
    }
}

