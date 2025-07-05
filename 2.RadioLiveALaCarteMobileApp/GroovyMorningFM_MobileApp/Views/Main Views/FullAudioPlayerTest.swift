import Foundation
import SwiftUI
import FFmpegSupport
import AVFoundation
import Combine
import Speech


struct FullAudioPlayerTest: View {
    
    let filesPrefixs: [String] = BigModel.shared.liveProgramsNames
    @ObservedObject var bigModel: BigModel = BigModel.shared
    
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height / 2
    let minHeight: CGFloat = UIScreen.main.bounds.height / 2
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    
    @State var disliked: Bool = false
    @State var liked: Bool = false
    
    @State var backgroundColor: Color = Color.gray
    
    @StateObject private var manager: AudioPlayerManager952025 = AudioPlayerManager952025.shared
            
    var body: some View {
        ZStack {
            
            Color(hex: bigModel.playerBackgroudColor.toHexString())
                .ignoresSafeArea()
            
            VStack {
                
                Image(systemName: "house")
                    .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                    .onTapGesture {
                        bigModel.currentView = .ProgramScreen
                    }
                
                Spacer()
                
                
                if (!manager.keywordFound) {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1)
                            .padding()
                            .foregroundStyle(Color.purple)
                        Spacer()
                    }.padding()
                } else {
                    VStack {
                        
                        AsyncImage(url: URL(string: bigModel.programs[bigModel.currentProgramIndex].favIcoURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            bigModel.extractDominantColor(from: image)
                                        }
                                    }
                            } else {
                                ProgressView()
                            }
                        }.padding()
                        
                        Text("\(formatTime(manager.currentTime)) / \(formatTime(manager.duration))")
                            .font(.headline)
                            .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Track
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.3))
                                    .frame(height: 4)
                                
                                // Filled track
                                Rectangle()
                                    .foregroundColor(.blue)
                                    .frame(width: CGFloat(manager.currentTime / manager.duration) * geo.size.width, height: 4)
                                
                                // Thumb (optionnel)
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(width: 12, height: 12)
                                    .offset(x: CGFloat(manager.currentTime / manager.duration) * geo.size.width - 6)
                            }
                            .contentShape(Rectangle()) // Permet de détecter les tap même en dehors du trait fin
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let ratio = min(max(0, value.location.x / geo.size.width), 1)
                                        let newVal = ratio * manager.duration
                                        manager.seek(to: newVal)
                                    }
                            )
                        }
                        .frame(height: 20)
                        .padding()
                        
                    }
                    .onChange(of: manager.player.rate) { oldValue, newValue in
                        manager.togglePlayPause()
                    }
                    .onChange(of: bigModel.currentProgramIndex) { oldValue, newValue in
                        manager.videLesSegments()
                        manager.startMonitoring()
                        /*if (manager.player.rate == 0) {
                            playing = true
                        }*/
                    }
                }
                
                HStack {
                    
                    Image(systemName: disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                        .onTapGesture {
                            
                            if (!disliked) {
                                if (liked) {
                                    bigModel.deleteFeedback { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            liked.toggle()
                                            bigModel.giveFeedback(feedback: "Bad") { result in
                                                switch result {
                                                case .success(let message):
                                                    print("Succès :", message)
                                                    disliked.toggle()
                                                case .failure(let error):
                                                    print("Erreur :", error.localizedDescription)
                                                }
                                            }
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                } else {
                                    bigModel.giveFeedback(feedback: "Bad") { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            disliked.toggle()
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                }
                            } else {
                                bigModel.deleteFeedback { result in
                                    switch result {
                                    case .success(let message):
                                        print("Succès :", message)
                                        liked.toggle()
                                    case .failure(let error):
                                        print("Erreur :", error.localizedDescription)
                                    }
                                }
                            }
                            
                        }
                    
                    Image(systemName: "backward.end.fill")
                        .font(.title)
                        .disabled(bigModel.currentProgramIndex == 0)
                        .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white)
                        .onTapGesture {
                            if bigModel.currentProgramIndex > 0 {
                                bigModel.currentProgramIndex -= 1
                            } else if !bigModel.delayedProgramsNames.isEmpty {
                                bigModel.currentView = .MultipleAudiosPlayer
                            }
                        }
                    
                    Button(action: {
                        manager.player.rate == 0 ? manager.player.play() : manager.player.pause()
                    }) {
                        Image(systemName: bigModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                    }
                    
                    Button(action: {
                        if bigModel.currentProgramIndex < filesPrefixs.count - 1 {
                            bigModel.currentProgramIndex += 1
                        }
                    }) {
                        Image(systemName: "forward.end.fill")
                            .font(.title)
                            .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                    }
                    .disabled(bigModel.currentProgramIndex == filesPrefixs.count - 1)
                    
                    Image(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                        .onTapGesture {
                            
                            if (!liked) {
                                if (disliked) {
                                    bigModel.deleteFeedback { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            disliked.toggle()
                                            bigModel.giveFeedback(feedback: "Good") { result in
                                                switch result {
                                                case .success(let message):
                                                    print("Succès :", message)
                                                    liked.toggle()
                                                case .failure(let error):
                                                    print("Erreur :", error.localizedDescription)
                                                }
                                            }
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                } else {
                                    bigModel.giveFeedback(feedback: "Good") { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            liked.toggle()
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                }
                            } else {
                                bigModel.deleteFeedback { result in
                                    switch result {
                                    case .success(let message):
                                        print("Succès :", message)
                                        liked.toggle()
                                    case .failure(let error):
                                        print("Erreur :", error.localizedDescription)
                                    }
                                }
                            }
                            
                        }
                    
                }
                .padding()
                
                Spacer()
            }
            
            BottomSheetView(offsetY: $offsetY, minHeight: minHeight, maxHeight: maxHeight, programs: bigModel.programs)
        }.onAppear {
            
            bigModel.getFeedback { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let feedback):
                        if feedback == "Good" {
                            liked = true
                            disliked = false
                        }
                        if feedback == "Bad" {
                            liked = false
                            disliked = true
                        }
                    case .failure(let error):
                        print("Erreur lors du chargement")
                        print(error.localizedDescription)
                    }
                }
            }
            
        }
        .onChange(of: bigModel.currentProgramIndex) { _ in
            // On change de programme => on télécharge et extrait la couleur
            let urlString = bigModel.programs[bigModel.currentProgramIndex].favIcoURL
            if let url = URL(string: urlString) {
                // Charge l'image (ici un AsyncImage ferait la même chose, mais pour la démo, on peut charger manuellement)
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, let uiImage = UIImage(data: data) else { return }
                    let swiftUIImage = Image(uiImage: uiImage)
                    Task { @MainActor in
                        bigModel.extractDominantColor(from: swiftUIImage)
                    }
                }
                task.resume()
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let intSec = Int(seconds)
        let minutes = intSec / 60
        let secs = intSec % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
}


