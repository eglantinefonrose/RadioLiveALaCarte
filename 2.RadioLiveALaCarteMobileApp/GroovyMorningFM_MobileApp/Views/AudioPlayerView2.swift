//
//  AudioPlayerView2.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 06/02/2025.
//

import SwiftUI

struct AudioPlayerView2: View {
    @StateObject private var audioPlayer = AudioPlayer()
    
    let urls = [
        URL(string: "http://localhost:8287/media/mp3/output_373f8ae9-b0d3-4ff2-bf22-f053497e5d75_17500.mp3")!,
        URL(string: "http://localhost:8287/media/mp3/output_194e848a-a986-437a-96e4-af42d9a62dc8_1850.mp3")!
    ]
    
    let specialUrls = [
        URL(string: "http://localhost:8287/media/mp3/output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_0000.mp3")!,
        URL(string: "http://localhost:8287/media/mp3/output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_0001.mp3")!,
        URL(string: "http://localhost:8287/media/mp3/output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_0002.mp3")!,
        URL(string: "http://localhost:8287/media/mp3/output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_0003.mp3")!
    ]
    
    let specialUrl: String = "output_ae5e2128-66e8-4509-906d-d5d17c529aec_1850output_"
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { audioPlayer.playPrevious() }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
                
                /*Button(action: { audioPlayer.rewind10Seconds() }) {
                    Image(systemName: "gobackward.10")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }*/
                
                Button(action: { audioPlayer.togglePlayPause() }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                }
                
                /*Button(action: { audioPlayer.moveForward10Seconds() }) {
                    Image(systemName: "goforward.10")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }*/
                
                Button(action: { audioPlayer.playNext() }) {
                    Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                Text(timeString(audioPlayer.currentTime))
                    .font(.caption)
                
                Slider(value: Binding(
                    get: { audioPlayer.currentTime },
                    set: { newValue in
                        audioPlayer.seek(to: newValue)
                    }
                ), in: 0...audioPlayer.duration)
                
                Text(timeString(audioPlayer.duration))
                    .font(.caption)
            }
            .padding()
        }
        .onAppear {
            audioPlayer.play(urls: urls, specialUrls: specialUrls)
        }
    }
    
    private func timeString(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

