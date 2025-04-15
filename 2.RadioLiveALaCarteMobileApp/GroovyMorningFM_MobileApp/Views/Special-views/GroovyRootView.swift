//
//  GroovyRootView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

import SwiftUI

struct GroovyRootView: View {
    
    @ObservedObject var bigModel: BigModel
    var danielMorinVersion: Bool
    
    var body: some View {
        
        VStack {
            if (BigModel.shared.currentView == .ProgramScreen) {
                ProgramScreen()
            }
            if (BigModel.shared.currentView == .AudioPlayerView) {
                //AudioPlayerView()
                AudioPlayerView_2237()
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
            if (BigModel.shared.currentView == .TestLivePlayer) {
                SandboxPlayerEnchainement()
            }
            if (BigModel.shared.currentView == .MultipleAudiosPlayer) {
                MultipleAudiosPlayer()
            }
            if (BigModel.shared.currentView == .SandboxPlayerEnchainement) {
                SandboxPlayerEnchainement()
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
    case TestLivePlayer
    case MultipleAudiosPlayer
    case SandboxPlayerEnchainement
}
