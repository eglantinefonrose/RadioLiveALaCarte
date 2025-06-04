//
//  GroovyRootView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

import SwiftUI

struct GroovyRootView: View {
    
    @StateObject var bigModel: BigModel
    var danielMorinVersion: Bool
    
    var body: some View {
        
        VStack {
            if (BigModel.shared.currentView == .ProgramScreen) {
                ProgramScreen()
            }
            if (BigModel.shared.currentView == .AudioPlayerView) {
                MultipleAudiosPlayer()
                //AudioPlayerView()
            }
            if (BigModel.shared.currentView == .NewProgramScreen) {
                NewProgramScreen()
            }
            if (BigModel.shared.currentView == .IpAdressView) {
                IPAdressView()
            }
            if (BigModel.shared.currentView == .DanielMorin) {
                AudioPlayerViewDanielMorin()
            }
            if (BigModel.shared.currentView == .LiveAudioPlayer) {
                SandboxPlayerLive()
            }
            if (BigModel.shared.currentView == .MultipleAudiosPlayer) {
                //MultipleAudiosPlayer()
                FullAudioPlayerTest()
                    .environmentObject(BigModel.shared)
            }
            
        }.onAppear {
            if (danielMorinVersion) {
                bigModel.currentView = .DanielMorin
            }
        }
        
    }
}

enum GroovyView {
    case ProgramScreen
    case AudioPlayerView
    case NewProgramScreen
    case IpAdressView
    case DanielMorin
    case LiveAudioPlayer
    case MultipleAudiosPlayer
}
