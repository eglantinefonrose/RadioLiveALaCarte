//
//  ProgramView.swift
//  Sandbox_Player_On_2_Views
//
//  Created by Eglantine Fonrose on 24/05/2025.
//

import SwiftUI

import SwiftUI

struct ProgramScreen: View {
    var body: some View {
        VStack {
            Text("Edito politique")
                .font(.title)
                .onTapGesture {
                    AudioManager.shared.play()
                    BigModel.shared.currentView = .PlayerScreen
                }
            Spacer()
        }
    }
}

struct PlayerScreen: View {
    var body: some View {
        VStack {
            Text("Lecture de : Edito politique")
                .font(.title2)
                .padding()
            Spacer()
            Text("Sortir")
                .onTapGesture {
                    BigModel.shared.currentView = .ProgramScreen
                }
        }
    }
}

struct BigRootView: View {
    
    @ObservedObject var bigModel = BigModel.shared
    @ObservedObject var audioManager = AudioManager.shared
    
    var body: some View {
        VStack {
            if bigModel.currentView == .ProgramScreen {
                ProgramScreen()
            } else if bigModel.currentView == .PlayerScreen {
                PlayerScreen()
            }
        }
    }
}

enum GroovyView {
    case ProgramScreen
    case PlayerScreen
}

class BigModel: ObservableObject {
    static let shared = BigModel()
    
    @Published var currentView: GroovyView = .ProgramScreen
}



