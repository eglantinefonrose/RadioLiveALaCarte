//
//  BigModel.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 17/02/2025.
//

//
//
// IMPORTANT
//
// Ici on choisit de rester sur une approche de classe uniquement (pas de protocol), car
// - Cela pourrait compliquer les mises à jour automatiques de la vue
// -  Perte de la possibilité de garantir que le protocole fournira une notification fiable des changements avec @Published
//

import Foundation
import SwiftUI
import AVFoundation
import Combine
import UIKit

class BigModel: ObservableObject {
    
    static let shared = BigModel()

    @Published var danielMorinVersion: Bool = false
    @Published var currentView: GroovyView = .ProgramScreen
    
    @Published var currentProgram: Program = Program(id: "", radioName: "", startTime: 0, endTime: 0, favIcoURL: "")
    @Published var programs: [Program] = []
    
    @Published var delayedProgramsNames: [String] = []
    @Published var liveProgramsNames: [String] = []
    @Published var currentProgramIndex: Int = 0/* {
        didSet {
            updateBackgroundColor()
        }
    }*/
    
    @Published var currentDelayedProgramIndex: Int = 0
    @Published var currentLiveProgramIndex: Int = 0
    
    @AppStorage("ipAddress") var ipAdress: String = "localhost" {
        didSet {
            if !ipAdress.isEmpty {
                NotificationCenter.default.post(name: .ipAddressUpdated, object: nil)
            }
        }
    }
    @Published var viewHistoryList: [GroovyView] = []
    @Published var raw: Bool = true
    
    // Implémentation des méthodes du protocole
    func isPlayableVideo(url: URL) -> Bool {
        let asset = AVURLAsset(url: url)
        
        if asset.isPlayable && asset.isReadable {
            return true
        } else {
            return false
        }
    }

    func generateUrls() {
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        var delayedUrls: [String] = []
        for program in programs {
            if program.isProgramAvailable() {
                let fileName = program.id + ".mp4"
                let fileURL = documentsURL.appendingPathComponent(fileName)
                
                if (isPlayableVideo(url: fileURL)) {
                    delayedUrls.append(fileName)
                }
            }
        }
        delayedProgramsNames = delayedUrls

        var liveUrls: [String] = []
        for program in programs {
            //if program.isInLive() {
                liveUrls.append(program.id)
            //}
        }
        liveProgramsNames = liveUrls
    }
    
    func verifierValeur(index: Int) -> Int {
        if index <= (self.delayedProgramsNames.count) {
            self.currentDelayedProgramIndex = index
            self.currentLiveProgramIndex = 0
            return 1
        } else if ( ( (index+1) > (self.delayedProgramsNames.count)) && ( (index+1) <= (delayedProgramsNames.count + liveProgramsNames.count)) ) {
            self.currentDelayedProgramIndex = self.delayedProgramsNames.count - 1
            self.currentLiveProgramIndex = index - self.delayedProgramsNames.count
            return 2
        } else {
            return 0
        }
    }
    
    //
    //
    // PLAYER UI
    //
    //
    @Published var isPlaying: Bool = true
    @Published var playerBackgroudColorHexCode: String = "#A357D7"
    @Published var isAnAudioSelected: Bool = false
    
    private func dominantColorHex(from image: UIImage) -> String {
        guard let cgImage = image.cgImage else {
            return "#AF52DE"
        }

        let width = 50
        let height = 50

        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            return "#AF52DE"
        }

        context.interpolationQuality = .low
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else {
            return "#AF52DE"
        }

        let pixelBuffer = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        var colorCount: [UInt32: Int] = [:]

        for x in 0..<width {
            for y in 0..<height {
                let offset = 4 * (y * width + x)
                let r = pixelBuffer[offset]
                let g = pixelBuffer[offset + 1]
                let b = pixelBuffer[offset + 2]

                let rgb = (UInt32(r) << 16) | (UInt32(g) << 8) | UInt32(b)
                colorCount[rgb, default: 0] += 1
            }
        }

        guard let (dominantRGB, _) = colorCount.max(by: { $0.value < $1.value }) else {
            return "#AF52DE"
        }

        let r = (dominantRGB >> 16) & 0xFF
        let g = (dominantRGB >> 8) & 0xFF
        let b = dominantRGB & 0xFF

        return String(format: "#%02X%02X%02X", r, g, b)
    }


    func updateBackgroundColor(from urlString: String) {
        
        guard let url = URL(string: urlString) else { return }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    //let color = extractDominantColor(from: image)
                    await MainActor.run {
                        self.playerBackgroudColorHexCode = self.dominantColorHex(from: image)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.playerBackgroudColorHexCode = "#AF52DE"
                    }
                }
            } catch {
                print("Erreur de chargement image: \(error)")
                self.playerBackgroudColorHexCode = "#AF52DE"
            }
        }
        
    }
    
    //
    //
    // FEEDBACK
    //
    //
    
    func giveFeedback(feedback: String, completion: @escaping (Result<String, Error>) -> Void) {
            // Construction correcte de l'URL
        let urlString = "http://\(self.ipAdress):8287/api/radio/createFeedback/programID/\(self.programs[self.currentProgramIndex].id)/feedback/\(feedback)"
            print(urlString)
            
            // Vérification de l'URL valide
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "URL invalide", code: 400, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Exécution de la requête
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Vérification d'une erreur réseau
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                // Vérification du code HTTP
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        completion(.success("Requête réussie avec statut \(httpResponse.statusCode)"))
                    }
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let errorMessage = "Requête échouée avec statut \(statusCode)"
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: errorMessage, code: statusCode, userInfo: nil)))
                    }
                }
            }.resume()
        }
        
        func deleteFeedback(completion: @escaping (Result<String, Error>) -> Void) {
            // Construction correcte de l'URL
            let urlString = "http://\(self.ipAdress):8287/api/radio/deleteFeedback/programID/\(self.programs[self.currentProgramIndex].id)"
            print(urlString)
            
            // Vérification de l'URL valide
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "URL invalide", code: 400, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Exécution de la requête
            URLSession.shared.dataTask(with: request) { data, response, error in
                // Vérification d'une erreur réseau
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                // Vérification du code HTTP
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        completion(.success("Requête réussie avec statut \(httpResponse.statusCode)"))
                    }
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    let errorMessage = "Requête échouée avec statut \(statusCode)"
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: errorMessage, code: statusCode, userInfo: nil)))
                    }
                }
            }.resume()
        }
    
    func getFeedback(completion: @escaping (Result<String, Error>) -> Void) {
            let urlString = "http://\(self.ipAdress):8287/api/radio/getFeedback/programID/\(self.programs[self.currentProgramIndex].id)"
            print(urlString)
            
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "URL invalide", code: 400, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    completion(.failure(NSError(domain: "Requête échouée", code: statusCode, userInfo: nil)))
                    return
                }
                
                if let data = data, let feedback = String(data: data, encoding: .utf8) {
                    completion(.success(feedback))
                } else {
                    completion(.failure(NSError(domain: "Données invalides", code: 500, userInfo: nil)))
                }
            }.resume()
        }
    
}

extension Notification.Name {
    static let ipAdressUpdated = Notification.Name("ipAdressUpdated")
}

extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

extension Color {
    func toUIColor() -> UIColor {
        let components = UIColor(self).cgColor.components ?? [0,0,0,0]
        return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components.count >= 4 ? components[3] : 1)
    }
}

extension String {
    /// Retourne `true` si la couleur hex est considérée comme "claire" (plus proche du blanc)
    var isLightColor: Bool {
        guard let color = UIColor(named: self) else { return false }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Luminance perçue (formule standard pour le contraste)
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        return luminance > 0.5
    }
}

