import SwiftUI

struct AudioPlayerViewDanielMorin: View {
    
    @StateObject private var audioManager = AudioPlayerManager()

    var body: some View {
        
        VStack {
            
            Spacer()
            
            VStack(spacing: 10) {
                
                Image("400x400_sc_le-billet-de-daniel-morin")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                            
                Text("Le billet de Daniel Morin")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)

                // Affichage de l'état de la lecture
                Text("France Inter")
                    .font(.headline)
                    .foregroundColor(.gray)

                // Barre de progression du temps de lecture
                Slider(value: $audioManager.currentTime, in: 0...audioManager.duration, onEditingChanged: { isEditing in
                    if !isEditing {
                        audioManager.seek(to: audioManager.currentTime)
                    }
                })
                .padding()

                // Affichage du temps écoulé et de la durée totale
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .foregroundColor(.white)
                    Spacer()
                    Text(formatTime(audioManager.duration))
                        .foregroundColor(.white)
                }
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal, 20)

                // Boutons de contrôle
                HStack(spacing: 30) {
                    
                    Image(systemName: "gobackward.10")
                        .font(.title)
                        .foregroundColor(.white)
                        .onTapGesture {
                            audioManager.seek(to: max(audioManager.currentTime - 10, 0)) // Retour de 10 secondes
                        }
                    
                    Image(systemName: "backward.end.fill")
                        .onTapGesture {
                            audioManager.previousTrack()
                        }
                        .foregroundColor(.white)
                    
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 75, height: 75)
                        .foregroundColor(.white)
                        .onTapGesture {
                            audioManager.playPause()
                        }
                    
                    Image(systemName: "forward.end.fill")
                        .onTapGesture {
                            audioManager.nextTrack()
                        }
                        .foregroundColor(.white)

                    Image(systemName: "goforward.10")
                        .font(.title)
                        .foregroundColor(.white)
                        .onTapGesture {
                            audioManager.seek(to: min(audioManager.currentTime + 10, audioManager.duration)) // Avance de 10 secondes
                        }
                    
                }
                
                VStack {
                    Text("Programmer l'enregistrement de Daniel Morin pour demain (7:57 - 8:00)")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(15)
                }.background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 25)
                .onTapGesture {
                    APIService.shared.creerHoraireDanielMorin()
                }
                
            }
            
            Spacer()
            
        }.edgesIgnoringSafeArea(.all)
        .background(Color(red: 203/255, green: 43/255, blue: 57/255))
    }

    // Fonction pour formater le temps en mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    AudioPlayerViewDanielMorin()
}

