import SwiftUI

struct Sandbox: View {
    
    @StateObject private var audioManager = AudioPlayerManager()
    
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height / 2
    let minHeight: CGFloat = UIScreen.main.bounds.height / 2
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    @ObservedObject private var bigModel: BigModel = BigModel.shared

    var body: some View {
        
        ZStack {
                        
            VStack(spacing: 20) {
                Text("🎵 Lecture Audio")
                    .font(.title)
                    .bold()
                
                // Affichage de l'état de la lecture
                if audioManager.isPlaying {
                    Text("Lecture en cours...")
                        .font(.headline)
                        .foregroundColor(.green)
                } else {
                    Text("Prêt à jouer")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    
                    if (audioManager.areThereAnyAudiosAvailable()) {
                        
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
                            
                            Image(systemName: "backward.fill")
                                .onTapGesture {
                                    audioManager.previousTrack()
                                }
                            
                            Button(action: {
                                audioManager.playPause()
                            }) {
                                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.largeTitle)
                            }
                            
                            Image(systemName: "forward.fill")
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
                        
                    } else {
                        Text("No programs are available today")
                    }
                    
                }
                
                Text("Lancer l'enregistrement de la chronique de Daniel Morin")
                    .onTapGesture {
                        APIService.shared.creerHoraireDanielMorin()
                    }
                
                Spacer()
            }
            .padding()
            
            BottomSheetView(audioManager: audioManager, offsetY: $offsetY, minHeight: minHeight, maxHeight: maxHeight, programs: bigModel.programs)
            
        }
        
    }

    // Fonction pour formater le temps en mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct BottomSheetView: View {
    
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
}
