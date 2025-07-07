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
    var startTime: Int
    var endTime: Int
    var favIcoURL: String
        
    init(id: String, radioName: String, startTime: Int, endTime: Int, favIcoURL: String) {
        self.id = id
        self.radioName = radioName
        self.startTime = startTime
        self.endTime = endTime
        self.favIcoURL = favIcoURL
    }
    
    static func == (lhs: Program, rhs: Program) -> Bool {
        return lhs.id == rhs.id
    }
    
    func isProgramAvailable() -> Bool {
        return ( !(ProgramManager.shared.estDansLeFutur(startTime: startTime)) && !(isInLive()) )
    }
    
    func isInLive() -> Bool {
        return (ProgramManager.shared.estEnLive(startTime: startTime, endTime: endTime))
    }
    
}
