//
//  RecordingServiceProtocol.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import Foundation

protocol RecordingServiceProtocol {
    func startTimer(for targetTime: Date, radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String)
    func recordRadio(radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, outputName: String)
    func recordRadioMocked()
}
