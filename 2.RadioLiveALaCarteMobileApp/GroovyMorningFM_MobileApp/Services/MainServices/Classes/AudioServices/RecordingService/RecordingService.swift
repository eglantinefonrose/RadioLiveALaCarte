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

class RecordingService: RecordingServiceProtocol {
    
    static let shared = RecordingService()
    
    func startTimer(for targetTime: Date, radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String, url: String) {
        
        print("horaire : \(startTimeHour), \(startTimeMinute), \(startTimeSeconds)")
        
        let timer = Timer.scheduledTimer(withTimeInterval: targetTime.timeIntervalSinceNow, repeats: false) { _ in
            self.recordRadio(radioName: radioName, startTimeHour: startTimeHour, startTimeMinute: startTimeMinute, startTimeSeconds: startTimeSeconds, outputName: outputName, url: url)
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func recordRadio(radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String, url: String) {
        
        /*let urlString = "http://\(BigModel.shared.ipAdress):8287/api/radio/getURLByName/name/\(radioName)"
        
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
            let outputURL = documentsDirectory.appendingPathComponent("\(outputName).mp4")

            print("streamURLString = \(streamURLString)")*/
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent("\(outputName).mp4")
            
        let ffmpegCommand = [
            "ffmpeg",
            "-i", "\(url)",
            "-t", "50",
            "-map", "0:a",
            "-c:a", "aac",
            "-b:a", "128k",
            "-f", "tee",
            "[f=mp4]\(outputURL.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/\(outputName)_%03d.mp4"
            
        ]
        
        ffmpeg(ffmpegCommand)
            
        //}
        
        //task.resume()
    }
    
    func recordRadioMocked() {
           
        let uuid = UUID().uuidString

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = "/Users/eglantine/Desktop/Test_ffmpeg/output_info_\(uuid).mp4"
        
        let ffmpegCommand1 = [
            "ffmpeg",
            "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
            "-t", "50",
            "-map", "0:a",
            "-c:a", "aac",
            "-b:a", "128k",
            "-f", "tee",
            "[f=mp4]\(outputURL)|[f=segment:segment_time=5:reset_timestamps=1]/Users/eglantine/Desktop/Test_ffmpeg/outputName\(uuid)_%03d.mp4"
            
        ]
        
        ffmpeg(ffmpegCommand1)
        
    }
    
}
