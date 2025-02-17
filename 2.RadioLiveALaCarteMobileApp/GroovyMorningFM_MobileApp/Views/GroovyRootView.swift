//
//  GroovyRootView.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

import SwiftUI

struct GroovyRootView: View {
    
    @ObservedObject var apiService: APIService
    
    var body: some View {
        
        if (APIService.shared.currentView == .ProgramScreen) {
            ProgramScreen()
        }
        if (APIService.shared.currentView == .AudioPlayerView) {
            Sandbox()
        }
        
    }
}

enum GroovyView {
    case ProgramScreen
    case AudioPlayerView
}
