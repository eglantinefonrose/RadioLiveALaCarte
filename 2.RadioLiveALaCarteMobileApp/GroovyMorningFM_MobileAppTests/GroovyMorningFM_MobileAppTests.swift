//
//  GroovyMorningFM_MobileAppTests.swift
//  GroovyMorningFM_MobileAppTests
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import XCTest
import Speech
@testable import GroovyMorningFM_MobileApp

final class GroovyMorningFM_MobileAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testTranscriptionOfAudioFile() async throws {
        // Chemin vers ton fichier audio (doit être accessible dans le simulateur)
        let audioFilePath = "/Users/eglantine/Library/Developer/CoreSimulator/Devices/5427AE58-890A-4065-9F57-6783C33CD377/data/Containers/Data/Application/7F86FA0B-BD9D-4E99-898E-2A396B0BF4C6/Documents/ce1df3eb-9faa-43e1-bd72-0d48cc8f9b63_002.mp4"
        let audioURL = URL(fileURLWithPath: audioFilePath)

        let expectation = expectation(description: "Transcription terminée")

        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
        XCTAssertNotNil(recognizer, "SFSpeechRecognizer est indisponible")

        guard let recognizer = recognizer, recognizer.isAvailable else {
            XCTFail("Le moteur de reconnaissance vocale n’est pas disponible.")
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        recognizer.recognitionTask(with: request) { result, error in
            if let result = result, result.isFinal {
                print("🔤 Transcription : \(result.bestTranscription.formattedString)")
                XCTAssertFalse(result.bestTranscription.formattedString.isEmpty, "Transcription vide")
                expectation.fulfill()
            } else if let error = error {
                XCTFail("Erreur de transcription : \(error.localizedDescription)")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 30, handler: nil)
    }

}
