//
//  Program.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import Foundation

class Program: Codable, Identifiable {
    
    var id: String = UUID().uuidString
    var radioName: String
    var startTimeHour: Int
    var startTimeMinute: Int
    var startTimeSeconds: Int
    var endTimeHour: Int
    var endTimeMinute: Int
    var endTimeSeconds: Int
    
    init(id: String, radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, endTimeHour: Int, endTimeMinute: Int, endTimeSeconds: Int) {
        self.id = id
        self.radioName = radioName
        self.startTimeHour = startTimeHour
        self.startTimeMinute = startTimeMinute
        self.startTimeSeconds = startTimeSeconds
        self.endTimeHour = endTimeHour
        self.endTimeMinute = endTimeMinute
        self.endTimeSeconds = endTimeSeconds
    }
    
    func isProgramAvailable() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentComponents = calendar.dateComponents([.hour, .minute, .second], from: now)

        // Comparaison avec l'heure actuelle
        if let currentHour = currentComponents.hour,
           let currentMinute = currentComponents.minute,
           let currentSecond = currentComponents.second {
            
            if startTimeHour > currentHour {
                return false
            } else if startTimeHour == currentHour {
                if startTimeMinute > currentMinute {
                    return false
                } else if startTimeMinute == currentMinute {
                    return startTimeSeconds > currentSecond
                }
            }
        }
        
        return true
    }
    
}
