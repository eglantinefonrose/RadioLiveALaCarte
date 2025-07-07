//
//  GroovyMorningFM_MobileAppTests.swift
//  GroovyMorningFM_MobileAppTests
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import XCTest
import Speech
@testable import GroovyMorningFM_MobileApp
import UIKit

import Foundation
import SwiftUI
import AVFoundation
import Combine

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
    
    func testTranscriptionAudioFichier() throws {

        let expectation = self.expectation(description: "Transcription terminée")
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("franceinter_10s.wav")

        TranscriptionService.shared.transcrireAudioDepuisFichier(fileURL: fileURL) { result in
            switch result {
            case .success(let transcription):
                XCTAssertFalse(transcription.isEmpty, "La transcription ne doit pas être vide.")
                print("Transcription : \(transcription)")
            case .failure(let error):
                XCTFail("La transcription a échoué avec une erreur : \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testColor() {
        print(Color.purple.toUIColor().toHexString())
    }
    
    func testEpoc() {
        print(ProgramManager.shared.convertEpochToHHMMSS(epoch: 1751872149))
    }

    
}
