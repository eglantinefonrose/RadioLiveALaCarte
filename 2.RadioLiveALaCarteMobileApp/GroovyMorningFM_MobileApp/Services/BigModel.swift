//
//  BigModel.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

import Foundation
import SwiftUI
import AVFoundation

class BigModel: ObservableObject {
    
    static let shared = BigModel()
    
    @Published var danielMorinVersion: Bool = false
    @Published var currentView: GroovyView = .ProgramScreen
    @Published var currentProgram: Program = Program(id: "", radioName: "", startTimeHour: 0, startTimeMinute: 0, startTimeSeconds: 0, endTimeHour: 0, endTimeMinute: 0, endTimeSeconds: 0, favIcoURL: "")
    
    @Published var programs: [Program] = []
    
    @Published var delayedProgramsNames: [String] = []
    @Published var liveProgramsNames: [String] = []
    
    @Published var currentProgramIndex: Int = 0
    @AppStorage("ipAddress") var ipAdress: String = "localhost" {
        didSet {
            if !ipAdress.isEmpty {
                NotificationCenter.default.post(name: .ipAddressUpdated, object: nil)
            }
        }
    }
    @Published var viewHistoryList: [GroovyView] = []
    
    @Published var raw: Bool = true
    
    func isPlayableVideo(url: URL) -> Bool {
        let asset = AVURLAsset(url: url)
        
        // On vérifie si l'asset est "playable"
        if asset.isPlayable && asset.isReadable {
            return true
        } else {
            return false
        }
    }
    
}

extension Notification.Name {
    static let ipAdressUpdated = Notification.Name("ipAdressUpdated")
}
