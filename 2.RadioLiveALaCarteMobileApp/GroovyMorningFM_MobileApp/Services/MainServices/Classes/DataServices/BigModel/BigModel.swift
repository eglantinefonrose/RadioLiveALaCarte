//
//  BigModel.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

//
//
// IMPORTANT
//
// Ici on choisit de rester sur une approche de classe uniquement (pas de protocol), car
// - Cela pourrait compliquer les mises à jour automatiques de la vue
// -  Perte de la possibilité de garantir que le protocole fournira une notification fiable des changements avec @Published
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import UIKit

class BigModel: ObservableObject {
    
    static let shared = BigModel()

    @Published var danielMorinVersion: Bool = false
    @Published var currentView: GroovyView = .ProgramScreen
    
    @Published var currentProgram: Program = Program(id: "", radioName: "", startTimeHour: 0, startTimeMinute: 0, startTimeSeconds: 0, endTimeHour: 0, endTimeMinute: 0, endTimeSeconds: 0, favIcoURL: "")
    @Published var programs: [Program] = []
    
    @Published var delayedProgramsNames: [String] = []
    @Published var liveProgramsNames: [String] = []
    @Published var currentProgramIndex: Int = 0
    
    @Published var currentDelayedProgramIndex: Int = 0
    @Published var currentLiveProgramIndex: Int = 0
    
    @AppStorage("ipAddress") var ipAdress: String = "localhost" {
        didSet {
            if !ipAdress.isEmpty {
                NotificationCenter.default.post(name: .ipAddressUpdated, object: nil)
            }
        }
    }
    @Published var viewHistoryList: [GroovyView] = []
    @Published var raw: Bool = true
    
    // Implémentation des méthodes du protocole
    func isPlayableVideo(url: URL) -> Bool {
        let asset = AVURLAsset(url: url)
        
        if asset.isPlayable && asset.isReadable {
            return true
        } else {
            return false
        }
    }

    func generateUrls() {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        var delayedUrls: [String] = []
        for program in programs {
            if program.isProgramAvailable() {
                let fileName = program.id + ".mp4"
                let fileURL = documentsURL.appendingPathComponent(fileName)
                
                if (isPlayableVideo(url: fileURL)) {
                    delayedUrls.append(fileName)
                }
            }
        }
        delayedProgramsNames = delayedUrls

        var liveUrls: [String] = []
        for program in programs {
            //if program.isInLive() {
                liveUrls.append(program.id)
            //}
        }
        liveProgramsNames = liveUrls
    }
    
    func verifierValeur(index: Int) -> Int {
        if index <= (self.delayedProgramsNames.count) {
            self.currentDelayedProgramIndex = index
            self.currentLiveProgramIndex = 0
            return 1
        } else if ( ( (index+1) > (self.delayedProgramsNames.count)) && ( (index+1) <= (delayedProgramsNames.count + liveProgramsNames.count)) ) {
            self.currentDelayedProgramIndex = self.delayedProgramsNames.count - 1
            self.currentLiveProgramIndex = index - self.delayedProgramsNames.count
            return 2
        } else {
            return 0
        }
    }
    
    //
    //
    // PLAYER UI
    //
    //
    @Published var isPlaying: Bool = true
    @Published var playerBackgroudColor: Color = Color.gray
    @Published var isAnAudioSelected: Bool = false
    
    @MainActor
    func extractDominantColor(from image: Image) {
        let renderer = ImageRenderer(content: image)

        if let uiImage = renderer.uiImage {
            if let uiColor = uiImage.dominantColor() {
                DispatchQueue.main.async {
                    self.playerBackgroudColor = Color(uiColor)
                }
            } else {
                DispatchQueue.main.async {
                    self.playerBackgroudColor = .gray
                }
            }
        }
    }
    
}

extension Notification.Name {
    static let ipAdressUpdated = Notification.Name("ipAdressUpdated")
}
