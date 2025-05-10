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
                SFSpeechRecognizer.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        TranscriptionService.shared.transcrireAudioDepuisFichier { resultat in
                            switch resultat {
                            case .success(let transcription):
                                print("✅ Transcription : \(transcription)")
                            case .failure(let erreur):
                                print("❌ Erreur : \(erreur.localizedDescription)")
                            }
                        }
                    default:
                        print("❌ Autorisation non accordée")
                    }
                }

            }
    }

    
}

#Preview {
    TranscriptionTest()
}
