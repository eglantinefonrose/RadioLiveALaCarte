//
//  File.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import Foundation

class ProgramManager: ProgramManagerProtocol {
    
    static let shared = ProgramManager()
    
    public func estDansLeFutur(startTime: Int) -> Bool {
        let currentTime = Int(Date().timeIntervalSince1970)
        return startTime > currentTime
    }
    
    public func estEnLive(startTime: Int, endTime: Int) -> Bool {
        let currentTime = Int(Date().timeIntervalSince1970)
        return currentTime >= startTime && currentTime <= endTime
    }
    
    public func convertToTimeEpoch(startHour: Int, startMinute: Int, startSeconds: Int) -> Int? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current // Assurez-vous qu’on utilise le bon fuseau horaire

        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = startHour
        components.minute = startMinute
        components.second = startSeconds

        if let date = calendar.date(from: components) {
            return Int(date.timeIntervalSince1970)
        } else {
            return nil
        }
    }
    
    public func convertEpochToHHMMSS(epoch: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        formatter.timeZone = TimeZone.current // Ou spécifie une autre TimeZone si nécessaire
        return formatter.string(from: date)
    }

}

