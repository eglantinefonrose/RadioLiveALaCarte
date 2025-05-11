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
    
    /*func transcrireAudioDepuisFichier(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR")) else {
            completion(.failure(NSError(domain: "SpeechRecognizerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Impossible d'initialiser le recognizer."])))
            return
        }
        
        if !recognizer.isAvailable {
            completion(.failure(NSError(domain: "SpeechRecognizerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Le service de reconnaissance vocale n'est pas disponible."])))
            return
        }
        
        let request = SFSpeechURLRecognitionRequest(url: fileURL)

        for i in 0...10 {
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    completion(.failure(error))
                } else if let result = result, result.isFinal {
                    completion(.success(result.bestTranscription.formattedString))
                }
            }
        }
        
    }*/
    
    func transcrireAudioDepuisFichier(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
        
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
    
    // Renvoie toutes les transcriptions d'une liste d'URL
    func transcrireAudiosDepuisFichiers(urls: [URL], completion: @escaping (Result<[String], Error>) -> Void) {
        var transcriptions: [String] = []
        
        func transcrireSuivant(index: Int) {
            if index >= urls.count {
                completion(.success(transcriptions))
                return
            }

            let fileURL = urls[index]
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
                    transcriptions.append(result.bestTranscription.formattedString)
                    transcrireSuivant(index: index + 1)
                }
            }
        }

        transcrireSuivant(index: 0)
    }
    
    func findIndexWithFirstWordAppearance(urls: [URL], keyword: String, completion: @escaping (Int?) -> Void) {
        transcrireAudiosDepuisFichiers(urls: urls) { result in
            switch result {
            case .success(let transcriptions):
                for (index, string) in transcriptions.enumerated() {
                    if string.range(of: keyword, options: .caseInsensitive) != nil {
                        completion(index)
                        return
                    }
                }
                completion(nil) // mot-clé non trouvé
            case .failure(let error):
                print("Erreur lors de la transcription : \(error.localizedDescription)")
                completion(nil) // en cas d'erreur
            }
        }
    }
    
}

