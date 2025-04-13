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
            self.recordRadio(radioName: radioName, startTimeHour: startTimeHour, startTimeMinute: startTimeMinute, startTimeSeconds: startTimeSeconds, outputName: outputName)
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
            let outputURL = documentsDirectory.appendingPathComponent("\(outputName).mp4")

            print("streamURLString = \(streamURLString)")
            
            let ffmpegCommand = [
                "ffmpeg",
                "-i", "\(streamURLString)",
                "-t", "50",
                "-map", "0:a",
                "-c:a", "aac",
                "-b:a", "128k",
                "-f", "tee",
                "[f=mp4]\(outputURL.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/\(outputName)_%03d.mp4"
            ]

            DispatchQueue.global(qos: .userInitiated).async {
                ffmpeg(ffmpegCommand)
            }
            
        }
        
        task.resume()
    }
    
}
