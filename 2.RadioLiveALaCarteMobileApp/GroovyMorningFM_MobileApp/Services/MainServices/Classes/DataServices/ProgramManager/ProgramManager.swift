//
//  File.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import Foundation

class ProgramManager: ProgramManagerProtocol {
    
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
    
    public func estEnLive(heureDebut: Int, minuteDebut: Int, secondeDebut: Int, heureFin: Int, minuteFin: Int, secondeFin: Int) -> Bool {
        
        let calendrier = Calendar.current
        let maintenant = Date()
        
        // Obtenir la date actuelle avec uniquement les composantes heure, minute, seconde
        let composantsActuels = calendrier.dateComponents([.hour, .minute, .second], from: maintenant)
        
        // Créer les composants Date pour l'heure de début et de fin aujourd'hui
        var composantsDebut = composantsActuels
        composantsDebut.hour = heureDebut
        composantsDebut.minute = minuteDebut
        composantsDebut.second = secondeDebut
        
        var composantsFin = composantsActuels
        composantsFin.hour = heureFin
        composantsFin.minute = minuteFin
        composantsFin.second = secondeFin
        
        // Convertir les composants en Date
        guard let dateDebut = calendrier.date(from: composantsDebut),
              let dateFin = calendrier.date(from: composantsFin),
              let maintenantDate = calendrier.date(from: composantsActuels) else {
            return false
        }
        
        return maintenantDate >= dateDebut && maintenantDate < dateFin
    }
}

