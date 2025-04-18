import SwiftUI

struct AudioPlayerView_2237: View {
    @StateObject private var audioPlayer = AudioPlayerManager_2237()
    @State private var audioFiles: [String] = []
    @State private var currentIndex: Int? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Playlist Audio")
                .font(.title)
                .bold()

            if let index = currentIndex {
                Text(audioFiles[index])
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.middle)
            } else {
                Text("Aucun morceau sélectionné")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 40) {
                Button(action: previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                }
                .disabled(currentIndex == nil || currentIndex == 0)

                if audioPlayer.isPlaying {
                    Button(action: {
                        audioPlayer.pause()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 50))
                    }
                } else {
                    Button(action: {
                        playCurrentOrFirst()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                    }
                }

                Button(action: nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                }
                .disabled(currentIndex == nil || currentIndex == audioFiles.count - 1)
            }

            Divider()

            List(audioFiles.indices, id: \.self) { index in
                HStack {
                    Text(audioFiles[index])
                        .lineLimit(1)

                    Spacer()

                    if currentIndex == index && audioPlayer.isPlaying {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.green)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    playTrack(at: index)
                }
            }
            
            Button("Supprimer tous les fichiers") {
                for (index, _) in audioFiles.enumerated().reversed() {
                    deleteAudioFile(at: index)
                }
            }
            .foregroundColor(.red)

            
        }
        .padding()
        .onAppear(perform: loadAudioFiles)
    }

    private func loadAudioFiles() {
        
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            audioFiles = files
                .filter { $0.pathExtension == "m4a" || $0.pathExtension == "mp4" }
                .map { $0.lastPathComponent }
                .sorted() // tri par nom (tu peux changer si besoin)
        } catch {
            print("Erreur lors du chargement des fichiers audio : \(error.localizedDescription)")
        }
    }

    private func playTrack(at index: Int) {
        guard audioFiles.indices.contains(index) else { return }
        currentIndex = index
        audioPlayer.playAudio(named: audioFiles[index])
    }

    private func playCurrentOrFirst() {
        if let index = currentIndex {
            audioPlayer.resume()
        } else if !audioFiles.isEmpty {
            playTrack(at: 0)
        }
    }

    private func nextTrack() {
        guard let index = currentIndex, index < audioFiles.count - 1 else { return }
        playTrack(at: index + 1)
    }

    private func previousTrack() {
        guard let index = currentIndex, index > 0 else { return }
        playTrack(at: index - 1)
    }
    
    private func deleteAudioFile(at index: Int) {
        let fileName = audioFiles[index]
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        do {
            try FileManager.default.removeItem(at: fileURL)
            audioFiles.remove(at: index)
            if currentIndex == index {
                audioPlayer.stop()
                currentIndex = nil
            } else if let current = currentIndex, current > index {
                currentIndex = current - 1
            }
        } catch {
            print("Erreur lors de la suppression du fichier : \(error.localizedDescription)")
        }
    }

    
}

