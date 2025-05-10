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
                let path: String = "/Users/eglantine/Desktop/franceinter_10s.wav"
                transcribeFrenchAudio(from: path) { result in
                    switch result {
                    case .success(let transcription):
                        print("✅ Transcription réussie : \(transcription)")
                    case .failure(let error):
                        print("❌ Erreur : \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func transcribeFrenchAudio(from path: String, completion: @escaping (Result<String, Error>) -> Void) {
        let audioURL = URL(fileURLWithPath: path)

        let localeFR = Locale(identifier: "fr-FR")
        guard let recognizer = SFSpeechRecognizer(locale: localeFR), recognizer.isAvailable else {
            completion(.failure(NSError(domain: "SpeechRecognizerUnavailable", code: 1, userInfo: [NSLocalizedDescriptionKey: "Le reconnaisseur vocal français n'est pas disponible."])))
            return
        }

        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else {
                completion(.failure(NSError(domain: "SpeechRecognitionNotAuthorized", code: 2, userInfo: [NSLocalizedDescriptionKey: "Autorisation de reconnaissance vocale refusée."])))
                return
            }

            let request = SFSpeechURLRecognitionRequest(url: audioURL)

            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    completion(.failure(error))
                } else if let result = result, result.isFinal {
                    completion(.success(result.bestTranscription.formattedString))
                }
            }
        }
    }

    
}

#Preview {
    TranscriptionTest()
}
