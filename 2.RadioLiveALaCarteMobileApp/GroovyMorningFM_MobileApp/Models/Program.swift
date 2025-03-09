//
//  Program.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import Foundation

class Program: Codable, Identifiable, Equatable {
    
    var id: String = UUID().uuidString
    var radioName: String
    var startTimeHour: Int
    var startTimeMinute: Int
    var startTimeSeconds: Int
    var endTimeHour: Int
    var endTimeMinute: Int
    var endTimeSeconds: Int
    var favIcoURL: String
        
    init(id: String, radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, endTimeHour: Int, endTimeMinute: Int, endTimeSeconds: Int, favIcoURL: String) {
        self.id = id
        self.radioName = radioName
        self.startTimeHour = startTimeHour
        self.startTimeMinute = startTimeMinute
        self.startTimeSeconds = startTimeSeconds
        self.endTimeHour = endTimeHour
        self.endTimeMinute = endTimeMinute
        self.endTimeSeconds = endTimeSeconds
        self.favIcoURL = favIcoURL
    }
    
    static func == (lhs: Program, rhs: Program) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isProgramAvailable() -> Bool {
        return !(ProgramManager.shared.estDansLeFutur(heure: startTimeHour, minute: startTimeMinute, seconde: startTimeSeconds))
    }
    
}
