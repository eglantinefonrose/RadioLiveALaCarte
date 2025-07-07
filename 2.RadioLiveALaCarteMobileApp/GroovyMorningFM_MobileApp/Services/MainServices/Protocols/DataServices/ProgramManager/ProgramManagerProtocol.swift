//
//  fff.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import Foundation

protocol ProgramManagerProtocol {
    func estDansLeFutur(startTime: Int) -> Bool
    func estEnLive(startTime: Int, endTime: Int) -> Bool
}

