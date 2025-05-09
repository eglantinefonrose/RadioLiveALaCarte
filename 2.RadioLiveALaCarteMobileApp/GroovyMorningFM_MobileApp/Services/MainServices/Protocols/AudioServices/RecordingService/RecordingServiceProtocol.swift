//
//  RecordingServiceProtocol.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import Foundation

protocol RecordingServiceProtocol {
    func startTimer(for targetTime: Date, radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, delay: Int, outputName: String, url: String)
    func recordRadio(radioName: String, delay: Int, outputName: String, url: String)
    func recordRadioMocked()
}
