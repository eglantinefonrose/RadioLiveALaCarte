//
//  TranscriptionTest.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 10/05/2025.
//

import SwiftUI
import Speech

struct TranscriptionTest: View {
    
    var body: some View {
        Text("Hello")
            .onTapGesture {
                
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL0: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_000.mp4")
                let fileURL1: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_001.mp4")
                let fileURL2: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_002.mp4")
                let fileURL3: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_003.mp4")
                let fileURL4: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_004.mp4")
                let fileURL5: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_005.mp4")
                let fileURL6: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_006.mp4")
                let fileURL7: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_007.mp4")
                let fileURL8: URL = documentsURL.appendingPathComponent("2b1ef98a-3300-49fd-9ed7-a558ae28a5e4_008.mp4")
                let mesURLs: [URL] = [fileURL0, fileURL1, fileURL2, fileURL3, fileURL4, fileURL5, fileURL6, fileURL7, fileURL8]
                
                transcrireAudiosDepuisFichiers(urls: mesURLs) { result in
                    switch result {
                    case .success(let transcriptions):
                        print("Toutes les transcriptions ont réussi :")
                        for (index, text) in transcriptions.enumerated() {
                            print("Fichier \(index + 1): \(text)")
                            if text.localizedCaseInsensitiveContains("mobilisation") {
                                print("Trouvé à l'indice \(index)")
                            }
                        }
                    case .failure(let error):
                        print("Erreur lors de la transcription : \(error.localizedDescription)")
                    }
                }
            
        }

    }
    
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
    
}

#Preview {
    TranscriptionTest()
}
