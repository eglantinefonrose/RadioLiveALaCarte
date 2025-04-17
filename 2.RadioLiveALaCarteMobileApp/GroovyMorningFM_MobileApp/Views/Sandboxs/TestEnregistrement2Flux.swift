//
//  TestEnregistrement2Flux.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 15/04/2025.
//

import FFmpegSupport
import SwiftUI
import UIKit
import AVFoundation

struct TestEnregistrement2Flux: View {
    
    let ffmpegCommand1 = [
        "ffmpeg",
        "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
        "-t", "15",
        "-c", "copy",
        "/Users/eglantine/Desktop/output_1.mp4"
    ]

    let ffmpegCommand2 = [
        "ffmpeg",
        "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
        "-t", "10",
        "-c", "copy",
        "/Users/eglantine/Desktop/output_2.mp4"
        
    ]
    
    var body: some View {
        
        Spacer()
        
        Text("Start recording bb")
            .onTapGesture {
                
                let calendar = Calendar.current
                let currentDate = Date()
                let targetTime = calendar.date(bySettingHour: 13, minute: 39, second: 0, of: currentDate)!
                
                let timer = Timer.scheduledTimer(withTimeInterval: targetTime.timeIntervalSinceNow, repeats: false) { _ in
                    RecordingService.shared.recordRadioMocked()
                }
                
                let timer2 = Timer.scheduledTimer(withTimeInterval: targetTime.timeIntervalSinceNow, repeats: false) { _ in
                    RecordingService.shared.recordRadioMocked()
                }
                
                RunLoop.current.add(timer, forMode: .common)
                RunLoop.current.add(timer2, forMode: .common)
                
                //RecordingService.shared.startTimer(for: targetTime, radioName: "france inter", startTimeHour: 10, startTimeMinute: 3, startTimeSeconds: 30, outputName: "")
                //RecordingService.shared.startTimer(for: targetTime, radioName: "france inter", startTimeHour: 10, startTimeMinute: 3, startTimeSeconds: 30, outputName: "")
                
        }
        
        Spacer()
        
        Text("List")
            .onTapGesture {
            
                // Obtenir l'URL du dossier Documents
                let fileManager = FileManager.default
                guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    print("Impossible d'accéder au dossier Documents.")
                    return
                }
                
                do {
                    // Lister tous les fichiers dans le dossier
                    let files = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                    
                    // Filtrer uniquement les fichiers .mp4
                    let mp4Files = files.filter { $0.pathExtension.lowercased() == "mp4" }
                    
                    for fileURL in mp4Files {
                        let asset = AVAsset(url: fileURL)
                        let durationInSeconds = CMTimeGetSeconds(asset.duration)
                        
                        print("🎬 Fichier : \(fileURL.lastPathComponent)")
                        print("⏱️ Durée : \(durationInSeconds) secondes")
                        print("-----------------------------")
                    }
                    
                    if mp4Files.isEmpty {
                        print("Aucun fichier .mp4 trouvé dans le dossier Documents.")
                    }
                } catch {
                    print("Erreur lors de la lecture du dossier : \(error)")
                }
                
        }
        
        Spacer()
        
        Image(systemName: "trash")
            .onTapGesture {
                let fileManager = FileManager.default

                    // Obtenir le chemin du dossier Documents
                    guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        print("❌ Impossible d'accéder au dossier Documents.")
                        return
                    }

                    do {
                        let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)

                        for fileURL in fileURLs {
                            try fileManager.removeItem(at: fileURL)
                            print("🗑️ Supprimé : \(fileURL.lastPathComponent)")
                        }

                        print("✅ Tous les fichiers ont été supprimés.")
                    } catch {
                        print("❌ Erreur lors de la suppression des fichiers : \(error)")
                    }
            }
        
        Spacer()
        
    }

    
}
