//
//  TranscriptionService.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 10/05/2025.
//

import Foundation
import Speech

class TranscriptionService {
    
    static let shared = TranscriptionService()
    
    func transcrireAudioDepuisFichier(completion: @escaping (Result<String, Error>) -> Void) {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("franceinter_10s.wav")
        
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR")) else {
            completion(.failure(NSError(domain: "SpeechRecognizerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Impossible d'initialiser le recognizer."])))
            return
        }
        
        if !recognizer.isAvailable {
            completion(.failure(NSError(domain: "SpeechRecognizerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Le service de reconnaissance vocale n'est pas disponible."])))
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: fileURL)

        recognizer.recognitionTask(with: request) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let result = result, result.isFinal {
                completion(.success(result.bestTranscription.formattedString))
            }
        }
    }
    
}

