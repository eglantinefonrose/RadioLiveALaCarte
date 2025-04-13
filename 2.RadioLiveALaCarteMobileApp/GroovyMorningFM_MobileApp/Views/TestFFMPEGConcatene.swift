//
//  TestFFMPEGConcatene.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 12/04/2025.
//

import SwiftUI

struct TestFFMPEGConcatene: View {
    
    @StateObject private var audioManager = AudioManagerTest()
    @State private var audioFiles: [String] = []

    var body: some View {
        
        VStack {
            /*Button(audioManager.isPlaying ? "Stop" : "Play") {
                if audioManager.isPlaying {
                    audioManager.stop()
                } else {
                    audioManager.concatenateAndPlay()
                }
            }*/
            Text("r")
        }
        .padding()
        
    }
    
    /*private func loadAudioFiles() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            audioFiles = files
                .filter { $0.pathExtension == "m4a" || $0.pathExtension == "mp3" }
                .map { $0.lastPathComponent }
                .sorted() // tri par nom (tu peux changer si besoin)
        } catch {
            print("Erreur lors du chargement des fichiers audio : \(error.localizedDescription)")
        }
    }
    
    func deleteFile(filename: String) {
        // Récupère le répertoire Documents de l'application
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Crée le chemin complet vers le fichier à supprimer
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            // Vérifie si le fichier existe avant de le supprimer
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
                print("Le fichier a été supprimé avec succès.")
            } else {
                print("Le fichier n'existe pas.")
            }
        } catch {
            // En cas d'erreur lors de la suppression
            print("Erreur lors de la suppression du fichier : \(error.localizedDescription)")
        }
    }
    
    private func deleteAudioFile(index: Int) {
        let fileName = audioFiles[index]
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        do {
            try FileManager.default.removeItem(at: fileURL)
            audioFiles.remove(at: index)
        } catch {
            print("Erreur lors de la suppression du fichier : \(error.localizedDescription)")
        }
    }*/
    
}

#Preview {
    TestFFMPEGConcatene()
}
