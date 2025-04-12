//
//  SandboxTest.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 12/04/2025.
//

import SwiftUI
import FFmpegSupport

// '/Users/eglantine/Library/Developer/CoreSimulator/Devices/5427AE58-890A-4065-9F57-6783C33CD377/data/Containers/Data/Application/D936FBD8-262B-496F-8367-9406A0F1D9FF/Documents/2aa62cd2-e121-4e48-9c5e-4e0d7bda828a_001.m4a'

struct SandboxTest: View {
    
    @State private var audioFiles: [String] = []
    
    var body: some View {
        Text("Hello")
            .onAppear {
                
                /*loadAudioFiles()
                print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
                print(audioFiles[0])
                
                listAppFiles()*/
                
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let inputURL = documentsDirectory.appendingPathComponent("2aa62cd2-e121-4e48-9c5e-4e0d7bda828a_000.m4a")
                let outputURL = documentsDirectory.appendingPathComponent("output.m4a") // Le fichier de sortie que tu veux

                print(outputURL)

                let ffmpegCommand = [
                    "ffmpeg",
                    "-i", "\(inputURL)",
                    "\(outputURL)" // Ajoute le fichier de sortie ici
                ]
                
                DispatchQueue.global(qos: .userInitiated).async {
                    ffmpeg(ffmpegCommand)
                }
                
            }
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func listAppFiles() {
        let documentsURL = getDocumentsDirectory()

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: [.fileSizeKey])

            if fileURLs.isEmpty {
                print("📁 Aucun fichier trouvé dans Documents.")
            } else {
                print("📁 Fichiers dans Documents:")
                for fileURL in fileURLs {
                    do {
                        let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                        let fileSize = resourceValues.fileSize ?? 0
                        print("📄 \(fileURL.lastPathComponent) -> \(fileURL.path) (\(fileSize) octets)")
                    } catch {
                        print("⚠️ Impossible de lire la taille de \(fileURL.lastPathComponent): \(error)")
                    }
                }
            }
        } catch {
            print("❌ Erreur lors de la lecture du dossier Documents: \(error)")
        }
    }
        
    
    
}

#Preview {
    SandboxTest()
}
