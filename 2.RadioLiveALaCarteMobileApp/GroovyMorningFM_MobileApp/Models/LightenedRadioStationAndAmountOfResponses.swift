//
//  LightenedRadioStationAndAmountOfResponses.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 23/02/2025.
//

import Foundation

public struct LightenedRadioStationAndAmountOfResponses: Decodable, Identifiable {
    public var id = UUID().uuidString
    var lightenedRadioStations: [LightenedRadioStation]
    var amountOfResponses: Int
}

