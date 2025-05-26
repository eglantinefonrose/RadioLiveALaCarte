//
//  LaunchScreen.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 26/05/2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.purple.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "music.note")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1.2 : 1.0)
                    .opacity(animate ? 1 : 0.6)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: animate)

                Text("Chargement...")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .onAppear {
            animate = true
        }
    }
}
