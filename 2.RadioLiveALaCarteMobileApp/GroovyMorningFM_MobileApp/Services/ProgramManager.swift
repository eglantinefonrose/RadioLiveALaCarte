//
//  ProgramManager.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 24/02/2025.
//

import Foundation

class ProgramManager {
    
    static let shared = ProgramManager()
    
    public func estDansLeFutur(heure: Int, minute: Int, seconde: Int) -> Bool {
        let calendrier = Calendar.current
        let maintenant = Date()
        
        var composants = calendrier.dateComponents([.year, .month, .day], from: maintenant)
        composants.hour = heure
        composants.minute = minute
        composants.second = seconde
        
        if let dateDonnee = calendrier.date(from: composants) {
            return dateDonnee > maintenant
        }
        
        return false
    }
    
}
