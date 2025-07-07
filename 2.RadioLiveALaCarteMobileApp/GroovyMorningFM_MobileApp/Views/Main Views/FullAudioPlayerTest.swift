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
    
    @State private var image: UIImage? = nil
    
    @StateObject private var manager: AudioPlayerManager952025 = AudioPlayerManager952025.shared
            
    var body: some View {
        ZStack {
            
            Color(hex: bigModel.playerBackgroudColorHexCode)
                .darker(by: 10)
                .ignoresSafeArea()
            
            VStack {
                                
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Image(systemName: "house")
                            .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white.darker(by: 10))
                            .onTapGesture {
                                bigModel.currentView = .ProgramScreen
                            }
                        
                        Spacer()
                            .frame(height: 5)
                        
                        Text(bigModel.programs[bigModel.currentProgramIndex].radioName)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                        
                        Text(ProgramManager.shared.convertEpochToHHMMSS(epoch: bigModel.programs[bigModel.currentProgramIndex].startTime))
                            .font(.largeTitle)
                            .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color(hex: "#363636") : Color(hex: "#D4D4D4"))
                        
                        /*bigModel.deleteFeedback { result in
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
                     }*/
                        
                        /*
                         bigModel.deleteFeedback { result in
                             switch result {
                             case .success(let message):
                                 print("Succès :", message)
                                 liked.toggle()
                             case .failure(let error):
                                 print("Erreur :", error.localizedDescription)
                             }
                         }
                         */
                        
                        HStack {
                            Image(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .font(.largeTitle)
                                .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                                .onTapGesture {
                                    
                                    if !disliked {
                                        
                                        if liked {
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
                                        else {
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
                                        
                                        if !liked {
                                            
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
                                            
                                        }
                                        
                                    }
                                    
                                }
                            
                            Image(systemName: disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                                .font(.largeTitle)
                                .onTapGesture {
                                    
                                    if !liked {
                                        
                                        if disliked {
                                            bigModel.deleteFeedback { result in
                                                switch result {
                                                    case .success(let message):
                                                        print("Succès :", message)
                                                        disliked.toggle()
                                                    case .failure(let error):
                                                        print("Erreur :", error.localizedDescription)
                                                }
                                            }
                                        }
                                        else {
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
                                        
                                        if !liked {
                                            
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
                                            
                                        }
                                        
                                    }
                                    
                                }
                        }
                    }
                    Spacer()
                }
                
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
                    
                    Spacer()
                    
                }
                
                VStack(spacing: 2) {
                    
                    GeometryReader { geometry in
                        let size = geometry.size.width / 3

                        HStack(spacing: 2) {
                            Button(action: {
                                if bigModel.currentProgramIndex > 0 {
                                    bigModel.currentProgramIndex -= 1
                                } else if !bigModel.delayedProgramsNames.isEmpty {
                                    bigModel.currentView = .MultipleAudiosPlayer
                                }
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(Color(hex: bigModel.playerBackgroudColorHexCode))
                                        .cornerRadius(16)
                                        .frame(width: size, height: size)
                                    Image(systemName: "backward.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: size * 0.4, height: size * 0.4)
                                        .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                                }
                            }

                            Button(action: {
                                if manager.player.rate == 0 {
                                    manager.player.play()
                                } else {
                                    manager.player.pause()
                                }
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(Color(hex: bigModel.playerBackgroudColorHexCode))
                                        .cornerRadius(16)
                                        .frame(width: size, height: size)
                                    Image(systemName: manager.player.rate == 0 ? "play.fill" : "pause")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: size * 0.4, height: size * 0.4)
                                        .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                                        .frame(width: size, height: size)
                                        .cornerRadius(16)
                                }
                            }

                            Button(action: {
                                if bigModel.currentProgramIndex < filesPrefixs.count - 1 {
                                    bigModel.currentProgramIndex += 1
                                }
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(Color(hex: bigModel.playerBackgroudColorHexCode))
                                        .cornerRadius(16)
                                        .frame(width: size, height: size)
                                    Image(systemName: "forward.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: size * 0.4, height: size * 0.4)
                                        .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                                        .frame(width: size, height: size)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.width / 3)
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Track
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            // Filled track
                            if (manager.duration != 0) {
                                Rectangle()
                                    .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                                    .frame(width: CGFloat(manager.currentTime / manager.duration) * geo.size.width, height: 4)
                            }
                            
                            // Thumb (optionnel)
                            Rectangle()
                                .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                                .frame(width: 4, height: 24)
                                .offset(x: CGFloat(manager.currentTime / manager.duration) * geo.size.width - 2)
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
                    .padding(.horizontal)
                                
                    HStack {
                        Text(formatTime(manager.currentTime))
                            .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                        Spacer()
                        Text(formatTime(manager.duration))
                            .foregroundStyle(bigModel.playerBackgroudColorHexCode.isLightColor ? Color.black : Color.white)
                    }.padding(.horizontal)
                    
                }
                
            }.padding()
            
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
        .onChange(of: manager.player.rate) { oldValue, newValue in
            manager.togglePlayPause()
        }
        .onChange(of: bigModel.currentProgramIndex) { oldValue, newValue in
            
            manager.videLesSegments()
            manager.startMonitoring()
            
            bigModel.updateBackgroundColor(from: bigModel.programs[bigModel.currentProgramIndex].favIcoURL)
            
        }
        
        .onChange(of: bigModel.currentProgramIndex) { _ in
            // On change de programme => on télécharge et extrait la couleur
            /*let urlString = bigModel.programs[bigModel.currentProgramIndex].favIcoURL
            if let url = URL(string: urlString) {
                // Charge l'image (ici un AsyncImage ferait la même chose, mais pour la démo, on peut charger manuellement)
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, let uiImage = UIImage(data: data) else { return }
                    let swiftUIImage = Image(uiImage: uiImage)
                    Task { @MainActor in
                        bigModel.dominantColorHex(from: swiftUIImage)
                    }
                }
                task.resume()
            }*/
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let intSec = Int(seconds)
        let minutes = intSec / 60
        let secs = intSec % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
}

