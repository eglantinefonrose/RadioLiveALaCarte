//
//  BigModel.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

import Foundation

class BigModel: ObservableObject {
    
    static let shared = BigModel()
    
    @Published var currentView: GroovyView = .AudioPlayerView
    @Published var currentProgram: Program = Program(id: "", radioName: "", startTimeHour: 0, startTimeMinute: 0, startTimeSeconds: 0, endTimeHour: 0, endTimeMinute: 0, endTimeSeconds: 0)
    @Published var programs: [Program] = []
    @Published var currentProgramIndex: Int = 0
    
}
