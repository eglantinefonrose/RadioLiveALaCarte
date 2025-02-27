//
//  BigModel.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

import Foundation
import SwiftUI

class BigModel: ObservableObject {
    
    static let shared = BigModel()
    
    @Published var currentView: GroovyView = .ProgramScreen
    @Published var currentProgram: Program = Program(id: "", radioName: "", startTimeHour: 0, startTimeMinute: 0, startTimeSeconds: 0, endTimeHour: 0, endTimeMinute: 0, endTimeSeconds: 0, favIcoURL: "")
    @Published var programs: [Program] = []
    @Published var currentProgramIndex: Int = 0
    @AppStorage("ipAddress") var ipAdress: String = "" {
        didSet {
            if !ipAdress.isEmpty {
                NotificationCenter.default.post(name: .ipAddressUpdated, object: nil)
            }
        }
    }
    
}
