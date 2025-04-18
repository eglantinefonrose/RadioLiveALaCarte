//
//  fff.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import Foundation

protocol ProgramManagerProtocol {
    func estDansLeFutur(heure: Int, minute: Int, seconde: Int) -> Bool
    func estEnLive(heureDebut: Int, minuteDebut: Int, secondeDebut: Int,
                   heureFin: Int, minuteFin: Int, secondeFin: Int) -> Bool
}

