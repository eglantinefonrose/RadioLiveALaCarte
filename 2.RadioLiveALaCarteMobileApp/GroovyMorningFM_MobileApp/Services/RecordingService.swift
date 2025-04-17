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
    
    func recordRadio(radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String) {
        
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
            
            let uuid = UUID().uuidString

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let outputURL = documentsDirectory.appendingPathComponent("output_info_\(uuid).mp4")

            print("streamURLString = \(streamURLString)")
            
            /*let ffmpegCommand = [
                "ffmpeg",
                "-i", "\(streamURLString)",
                "-t", "50",
                "-map", "0:a",
                "-c:a", "aac",
                "-b:a", "128k",
                "-f", "tee",
                "[f=mp4]\(outputURL.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/\(outputName)_%03d.mp4"
                
            ]*/
                        
            let ffmpegCommand1 = [
                "ffmpeg",
                "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
                "-t", "30",
                "-c", "copy",
                "\(outputURL.absoluteString)"
            ]
            /*DispatchQueue.global(qos: .userInitiated).async {
                ffmpeg(ffmpegCommand)
            }*/
            
            /*let group = DispatchGroup()
            
            group.enter()
            DispatchQueue.global(qos: .background).async {
                ffmpeg(ffmpegCommand1)
                group.leave()
            }*/
            
            ffmpeg(ffmpegCommand1)
            //ffmpeg(ffmpegCommand2)
            
        }
        
        task.resume()
    }
    
    func recordRadioMocked() {
           
        let uuid = UUID().uuidString

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent("output_info_\(uuid).mp4")
                    
        let ffmpegCommand1 = [
            "ffmpeg",
            "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
            "-t", "30",
            "-c", "copy",
            "\(outputURL.absoluteString)"
        ]
        
        ffmpeg(ffmpegCommand1)
        
    }
    
}
