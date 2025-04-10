//
//  ContentView.swift
//  Test-FFMPEG
//
//  Created by Eglantine Fonrose on 10/04/2025.
//

import SwiftUI
import FFmpegSupport

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .onTapGesture {
                    ffmpeg(["ffmpeg", "-i", "/Users/eglantine/Desktop/0331.mp4", "/Users/eglantine/Desktop/ffmpeg-test-10-4-2025.mp4"])
                }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
