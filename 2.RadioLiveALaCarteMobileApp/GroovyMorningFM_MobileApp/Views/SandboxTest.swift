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
            .onTapGesture {
                
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let outputURL1 = documentsDirectory.appendingPathComponent("prout_480408-51.mp4")
                
                let ffmpegCommand1 = [
                    "ffmpeg",
                    "-i", "https://stream.radiofrance.fr/franceinfo/franceinfo_hifi.m3u8?id=radiofrance",
                    "-t", "30",
                    "-map", "0:a",
                    "-c:a", "aac",
                    "-b:a", "128k",
                    "-f", "tee",
                    "[f=mp4]\(outputURL1.absoluteString)|[f=segment:segment_time=5:reset_timestamps=1]\(documentsDirectory.path)/segment_%03d.mp4"
                ]

                ffmpeg(ffmpegCommand1)
                
        }
    }
}

#Preview {
    SandboxTest()
}
