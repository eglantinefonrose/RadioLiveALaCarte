import SwiftUI

struct AudioPlayerView: View {
    
    @StateObject private var audioManager = AudioPlayerManager()
    
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height / 2
    let minHeight: CGFloat = UIScreen.main.bounds.height / 2
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @State var liked: Bool = false
    @State var disliked: Bool = false

    var body: some View {
        
        ZStack {
                        
            VStack(spacing: 20) {
                
                HStack {
                    Text("Back")
                        .bold()
                        .foregroundStyle(Color.blue)
                        .onTapGesture {
                            if (bigModel.viewHistoryList.count >= 2) {
                                bigModel.currentView = bigModel.viewHistoryList[bigModel.viewHistoryList.count-2]
                            }
                        }
                    Spacer()
                }
                
                Toggle("Show trimmed audios", isOn: $bigModel.raw)
                    .bold()
                    .padding(20)
                
                /*AsyncImage(url: URL(string: bigModel.programs[bigModel.currentProgramIndex].favIcoURL)){ result in
                            result.image?
                                .resizable()
                                .scaledToFill()
                        }
                        .frame(width: 100)*/
                
                VStack {
                    
                    //if (audioManager.areThereAnyAudiosAvailable()) {
                        
                        // Barre de progression du temps de lecture
                        Slider(value: $audioManager.currentTime, in: 0...audioManager.duration, onEditingChanged: { isEditing in
                            if !isEditing {
                                audioManager.seek(to: audioManager.currentTime)
                            }
                        })
                        .padding()
                        
                        // Affichage du temps écoulé et de la durée totale
                        HStack {
                            Text(formatTime(audioManager.currentTime)) // Temps actuel
                            Spacer()
                            Text(formatTime(audioManager.duration)) // Durée totale
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        
                        // Boutons de contrôle
                        HStack(spacing: 30) {
                            Button(action: {
                                audioManager.seek(to: max(audioManager.currentTime - 10, 0)) // Retour de 10 secondes
                            }) {
                                Image(systemName: "gobackward.10")
                                    .font(.title)
                            }
                            
                            Image(systemName: disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                            
                            Image(systemName: "backward.end.fill")
                                .onTapGesture {
                                    audioManager.previousTrack()
                                }
                            
                            Button(action: {
                                audioManager.playPause()
                            }) {
                                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.largeTitle)
                            }
                            
                            Image(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                            
                            Image(systemName: "forward.end.fill")
                                .onTapGesture {
                                    audioManager.nextTrack()
                                }
                            
                            Button(action: {
                                audioManager.seek(to: min(audioManager.currentTime + 10, audioManager.duration)) // Avance de 10 secondes
                            }) {
                                Image(systemName: "goforward.10")
                                    .font(.title)
                            }
                        }
                        .padding()
                        
                    /*} else {
                        Text("No programs are available today")
                    }*/
                    
                }
                
                Spacer()
            }
            .padding()
            
            //BottomSheetView(audioManager: audioManager, offsetY: $offsetY, minHeight: minHeight, maxHeight: maxHeight, programs: bigModel.programs)
            
        }.onAppear {
            bigModel.viewHistoryList.append(.AudioPlayerView)
        }
        .onChange(of: bigModel.raw) { oldValue, newValue in
            audioManager.loadAndPlay()
        }
        
    }

    // Fonction pour formater le temps en mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/*struct BottomSheetView: View {
    
    @StateObject var audioManager: AudioPlayerManager
    @ObservedObject var bigModel = BigModel.shared
    @Binding var offsetY: CGFloat
    let minHeight: CGFloat
    let maxHeight: CGFloat
    var programs: [Program]
    
    var body: some View {
        VStack {
            /*Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(.gray)
                .padding(.top, 10)*/

            List {
                ForEach(programs.indices, id: \.self) { index in
                    Text("\(programs[index].radioName)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontWeight(  (index == bigModel.currentProgramIndex) ? .bold : .regular)
                        .onTapGesture {
                            audioManager.updateCurrentProgramIndex(index: index)
                        }
                }
            }
            .frame(height: maxHeight - 50)
        }
        .frame(height: maxHeight)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(radius: 10))
        .offset(y: offsetY)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newOffset = offsetY + value.translation.height
                    offsetY = min(max(newOffset, minHeight), maxHeight)
                }
                .onEnded { value in
                    let midPoint = (minHeight + maxHeight) / 2
                    offsetY = offsetY > midPoint ? maxHeight : minHeight
                }
        )
        .animation(.spring(), value: offsetY)
    }
}*/
