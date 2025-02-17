import SwiftUI

struct Sandbox: View {
    @StateObject private var audioManager = AudioPlayerManager()

    var body: some View {
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
            
            Text("Lancer l'enregistrement de la chronique de Daniel Morin")
                .onTapGesture {
                    APIService.shared.creerHoraireDanielMorin()
                }

            Spacer()
        }
        .padding()
    }

    // Fonction pour formater le temps en mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


