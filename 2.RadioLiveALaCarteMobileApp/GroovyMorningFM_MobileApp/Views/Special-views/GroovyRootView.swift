//
//  GroovyRootView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

import SwiftUI

struct GroovyRootView: View {
    
    @ObservedObject var bigModel: BigModel
    
    var body: some View {
        
        if (BigModel.shared.currentView == .ProgramScreen) {
            ProgramScreen()
        }
        if (BigModel.shared.currentView == .AudioPlayerView) {
            AudioPlayerView()
        }
        if (BigModel.shared.currentView == .NewProgramScreen) {
            NewProgramScreen()
        }
        if (BigModel.shared.currentView == .IpAdressView) {
            IPAdressView()
        }
        
    }
}

enum GroovyView {
    case ProgramScreen
    case AudioPlayerView
    case NewProgramScreen
    case IpAdressView
}
