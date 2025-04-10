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
    
    func startTimer(for targetTime: Date, radioName: String, duration: Int) {
        let timer = Timer.scheduledTimer(withTimeInterval: targetTime.timeIntervalSinceNow, repeats: false) { _ in
            self.recordRadio(radioName: radioName, duration: duration)
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func recordRadio(radioName: String, duration: Int) {
        /*let urlString = "http://localhost:8287/api/radio/getURLByName/name/\(radioName)"
        
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
            }*/
            
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let uuid = UUID().uuidString
            let outputURL = documentsDirectory.appendingPathComponent("franceinter_\(uuid).mp3")

            let ffmpegCommand = [
                "ffmpeg",
                "-i", "http://direct.franceinter.fr/live/franceinter-midfi.mp3",
                "-t", "\(duration)",
                "-c", "copy",
                outputURL.path
            ]
            
            ffmpeg(ffmpegCommand)
        /*}
        
        task.resume()*/
    }
    
}
