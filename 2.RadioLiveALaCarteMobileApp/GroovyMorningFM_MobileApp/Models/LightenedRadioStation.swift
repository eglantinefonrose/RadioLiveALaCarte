//
//  LightenedRadioStation.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 23/02/2025.
//

import Foundation

public struct LightenedRadioStation: Decodable, Identifiable {
    
    public var id: String = UUID().uuidString
    var name: String
    var favicon: String
    var radioUUID: String
    
    init(id: String, name: String, favicon: String, url: String, radioUUID: String) {
        self.id = id
        self.name = name
        self.favicon = favicon
        self.radioUUID = radioUUID
    }
    
}
