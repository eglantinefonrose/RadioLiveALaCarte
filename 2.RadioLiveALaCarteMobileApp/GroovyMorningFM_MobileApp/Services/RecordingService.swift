//
//  RecordingService.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 10/04/2025.
//

import SwiftUI
import AVFoundation
import FFmpegSupport
import Foundation

class RecordingService {
    
    static let shared = RecordingService()
    
    func startTimer(for targetTime: Date, radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String) {
        
        print("horaire : \(startTimeHour), \(startTimeMinute), \(startTimeSeconds)")
        
        let timer = Timer.scheduledTimer(withTimeInterval: targetTime.timeIntervalSinceNow, repeats: false) { _ in
            self.recordRadio(radioName: radioName, startTimeHour: startTimeHour, startTimeMinute: startTimeMinute, startTimeSeconds: startTimeSeconds, outputName: "test_criveli")
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func recordRadio(radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String) {
        
        let urlString = "http://\(BigModel.shared.ipAdress):8287/api/radio/getURLByName/name/\(radioName)"
        
        guard let url = URL(string: urlString) else {
            print("URL invalide.")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors de la requête: \(error)")
                return
            }
            
            guard let data = data,
                  let streamURLString = String(data: data, encoding: .utf8),
                  let streamURL = URL(string: streamURLString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                print("Réponse invalide.")
                return
            }
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let outputURL = documentsDirectory.appendingPathComponent("\(outputName)_%03d.m4a")

            print("streamURLString = \(streamURLString)")

            let ffmpegCommand = [
                "ffmpeg",
                "-t", "180",                        // Durée totale d'enregistrement
                "-i", "\(streamURLString)",         // Source du flux
                "-c:a", "aac",                      // Codec audio
                "-b:a", "128k",                     // Bitrate audio
                "-vn",                              // Pas de vidéo
                "-f", "segment",                    // Format segmenté
                "-segment_time", "10",             // Durée de chaque segment
                "\(outputURL.path)"                // Fichier de sortie (avec modèle de nom)
            ]

            DispatchQueue.global(qos: .userInitiated).async {
                ffmpeg(ffmpegCommand)
            }
            
        }
        
        task.resume()
    }
    
}
