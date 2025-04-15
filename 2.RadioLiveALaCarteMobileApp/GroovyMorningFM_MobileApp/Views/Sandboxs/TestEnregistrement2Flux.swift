//
//  TestEnregistrement2Flux.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 15/04/2025.
//

import FFmpegSupport
import SwiftUI

struct TestEnregistrement2Flux: View {
    
    var body: some View {
        
        Text("Start recording bb")
            .onTapGesture {
                recordFranceRadios()
            }
        
    }
    
    func recordFranceRadios() {
        
        let group = DispatchGroup()

        // Commandes FFmpeg
        let franceInterCommand = [
            "ffmpeg",
            "-t", "10",
            "-i", "https://stream.radiofrance.fr/franceinter/franceinter_hifi.m3u8",
            "-c", "copy",
            "/Users/eglantine/Desktop/output_france_inter.mp4"
        ]

        let franceInfoCommand = [
            "ffmpeg",
            "-t", "10",
            "-i", "https://stream.radiofrance.fr/franceinter/franceinter_hifi.m3u8",
            "-c", "copy",
            "/Users/eglantine/Desktop/output_france_info.mp4"
        ]

        group.enter()
        DispatchQueue.global(qos: .background).async {
            ffmpeg(franceInterCommand)
            ffmpeg(franceInfoCommand)
            group.leave()
        }

        group.enter()
        /*DispatchQueue.global(qos: .background).async {
            ffmpeg(franceInfoCommand)
            group.leave()
        }*/

        group.notify(queue: .main) {
            print("✅ Les deux enregistrements sont terminés.")
            print("🎧 France Inter : output_france_inter.mp4")
            print("🎧 France Info  : output_france_info.mp4")
        }

        
    }

    
}
