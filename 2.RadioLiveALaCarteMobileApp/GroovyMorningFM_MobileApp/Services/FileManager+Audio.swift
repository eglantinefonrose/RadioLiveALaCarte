//
//  FileManager+Audio.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 11/04/2025.
//

import Foundation

extension FileManager {
    func listAudioFiles() -> [URL] {
        let documentsURL = urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let files = try contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return files.filter { $0.pathExtension == "m4a" || $0.pathExtension == "mp3" }
        } catch {
            print("Erreur lors du chargement des fichiers: \(error)")
            return []
        }
    }
}
