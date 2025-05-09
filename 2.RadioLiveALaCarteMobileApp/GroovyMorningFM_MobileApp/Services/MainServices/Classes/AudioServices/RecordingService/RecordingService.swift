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
    
    func startTimer(for targetTime: Date, radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, delay: Int, outputName: String, url: String) {
                
        let timer = Timer.scheduledTimer(withTimeInterval: targetTime.timeIntervalSinceNow, repeats: false) { _ in
            self.recordRadio(radioName: radioName, delay: delay, outputName: outputName, url: url)
        }
        RunLoop.current.add(timer, forMode: .common)
    }
    
    /*func recordRadio(radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String, url: String) {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent("\(outputName).mp4")
        let group = DispatchGroup()
            
        let ffmpegCommand1 = [
            "ffmpeg",
            "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
            "-t", "300",
            "-map", "0:a",
            "-c:a", "aac",
            "-b:a", "128k",
            "-f", "tee",
            "[f=mp4]\(outputURL.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/\(outputName)1_%03d.mp4"
        ]
        
        let ffmpegCommand2 = [
            "ffmpeg",
            "-i", "https://stream.radiofrance.fr/franceinter/franceinter_hifi.m3u8?id=radiofrance",
            "-t", "300",
            "-map", "0:a",
            "-c:a", "aac",
            "-b:a", "128k",
            "-f", "tee",
            "[f=mp4]\(outputURL.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/\(outputName)2_%03d.mp4"
        ]
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            ffmpeg(ffmpegCommand1)
            ffmpeg(ffmpegCommand2)
            group.leave()
        }
        
    }*/
    
    func recordRadio(radioName: String, delay: Int, outputName: String, url: String) {
            
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputURL = documentsDirectory.appendingPathComponent("\(outputName).mp4")
        let group = DispatchGroup()

        let ffmpegCommand1 = [
            "ffmpeg",
            "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
            "-t", "\(delay)",
            "-c", "copy",
            "-f", "segment",
            "-segment_time", "5",
            "-reset_timestamps", "1",
            "\(documentsDirectory.path)/\(outputName)_%03d.mp4"
        ]
        
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            ffmpeg(ffmpegCommand1)
            group.leave()
        }
        
    }
    
    func recordRadioMocked() {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let uuid = UUID().uuidString
        let outputURL = documentsDirectory.appendingPathComponent("output_\(uuid).mp4")
            
        let ffmpegCommand = [
            "ffmpeg",
            "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
            "-t", "50",
            "-map", "0:a",
            "-c:a", "aac",
            "-b:a", "128k",
            "-f", "tee",
            "[f=mp4]\(outputURL.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/output_\(uuid)_%03d.mp4"
            
        ]
        
        ffmpeg(ffmpegCommand)
    }
    
}
