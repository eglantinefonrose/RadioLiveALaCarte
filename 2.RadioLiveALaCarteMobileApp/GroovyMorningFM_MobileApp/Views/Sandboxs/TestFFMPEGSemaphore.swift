//
//  TestFFMPEGSemaphore.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 16/04/2025.
//

import Foundation
import FFmpegSupport

// Le sémaphore, avec une "capacité" de 1
let ffmpegSemaphore = DispatchSemaphore(value: 1)

// Fonction qui exécute la commande FFmpeg de manière safe
func runFFmpegSafely(command: String) {
    DispatchQueue.global(qos: .background).async {
        // Attendre que le sémaphore soit dispo (c'est bloquant si une autre commande tourne)
        ffmpegSemaphore.wait()
        print("▶️ Début de la commande : \(command)")

        // Lancer FFmpeg (à adapter selon ton binding)
        ffmpeg(command)

        print("✅ Fin de la commande : \(command)")
        // Libérer le sémaphore pour la commande suivante
        ffmpegSemaphore.signal()
    }
}
