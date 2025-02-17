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
            Sandbox()
        }
        
    }
}

enum GroovyView {
    case ProgramScreen
    case AudioPlayerView
}
