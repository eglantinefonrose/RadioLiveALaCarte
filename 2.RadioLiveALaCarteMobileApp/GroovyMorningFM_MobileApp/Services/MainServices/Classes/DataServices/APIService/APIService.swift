//
//  APIService.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import Foundation

class APIService: ObservableObject, APIServiceProtocol {
    
    static let shared = APIService()
    let bigModel: BigModel = BigModel.shared
    
    func validerHoraire(
        radioName: String,
        startTime: Int,
        endTime: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Construction correcte de l'URL
        let urlString = "http://\(bigModel.ipAdress):8287/api/radio/createProgram/radioName/\(radioName)/startTime/\(startTime)/endTime/\(endTime)/userID/user001/danielMorinVersion/0"
        
        // Vérification de l'URL valide
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "URL invalide", code: 400, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 3 // Timeout de 3 secondes
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
    
    func createProgram(
        radioName: String,
        startTime: Int,
        endTime: Int,
        radioUUID: String
    ) async throws -> String {
            
        do {
                        
            let urlString = "http://\(bigModel.ipAdress):8287/api/radio/createProgram/radioName/\(radioName)/startTime/\(startTime)/endTime/\(endTime)/userID/user001/danielMorinVersion/0"
            // api/radio/createProgram/radioName/FranceInter/startTime/1751872149/endTime/1751872199/userID/user001/danielMorinVersion/0
            
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let responseString = String(data: data, encoding: .utf8) {
                print(urlString)
                return responseString
            } else {
                throw URLError(.cannotDecodeContentData)
            }
            
        } catch {
            print("error")
        }
        
        return ""
            
    }


    func creerHoraireDanielMorin() {
        let urlString = "http://\(bigModel.ipAdress):8287/api/radio/createAndRecordProgram/radioName/FranceInter/startTimeHour/6/startTimeMinute/57/startTimeSeconds/0/endTimeHour/7/endTimeMinute/0/endTimeSeconds/1/userID/user001/danielMorinVersion/0"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur :", error.localizedDescription)
            } else {
                print("Requête envoyée avec succès à :", urlString)
            }
        }.resume()
    }
    
    func fetchPrograms(for userId: String) async -> [Program] {
        
        let urlString = "http://\(bigModel.ipAdress):8287/api/radio/getProgramsByUser/userId/\(userId)"
        print(urlString)
        guard let url = URL(string: urlString) else {
            return []
        }
        
        let maxRetries = 5
        let delay: UInt64 = 2_000_000_000 // 2 secondes en nanosecondes
        
        for attempt in 1...maxRetries {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let programs = try JSONDecoder().decode([Program].self, from: data)
                return programs
            } catch {
                print("Tentative \(attempt) échouée: \(error.localizedDescription)")
                if attempt < maxRetries {
                    try? await Task.sleep(nanoseconds: delay)
                }
            }
        }
        
        return []
    }
    
    static func fetchFilesWithoutSegmentNames(for userId: String, completion: @escaping ([String]) -> Void) {
        let urlString = "http://example.com/getFilesWithoutSegmentNamesList/userId/\(userId)"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur :", error.localizedDescription)
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let fileList = try JSONDecoder().decode([String].self, from: data)
                DispatchQueue.main.async {
                    completion(fileList)
                }
            } catch {
                print("Erreur de décodage :", error.localizedDescription)
                completion([])
            }
        }.resume()
    }
    
    func searchByName(for name: String, completion: @escaping (LightenedRadioStationAndAmountOfResponses) -> Void) {
        
        let urlString = "http://\(bigModel.ipAdress):8287/api/radio/lightenSearchByName/\(name)"
        print(urlString)
        
        guard let url = URL(string: urlString) else {
            completion(LightenedRadioStationAndAmountOfResponses(lightenedRadioStations: [], amountOfResponses: 0))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur :", error.localizedDescription)
                completion(LightenedRadioStationAndAmountOfResponses(lightenedRadioStations: [], amountOfResponses: 0))
                return
            }
            
            guard let data = data else {
                completion(LightenedRadioStationAndAmountOfResponses(lightenedRadioStations: [], amountOfResponses: 0))
                return
            }
            
            do {
                let fileList = try JSONDecoder().decode(LightenedRadioStationAndAmountOfResponses.self, from: data)
                DispatchQueue.main.async {
                    completion(fileList)
                }
            } catch {
                print("Erreur de décodage :", error.localizedDescription)
                print(data)
                completion(LightenedRadioStationAndAmountOfResponses(lightenedRadioStations: [], amountOfResponses: 0))
            }
        }.resume()
        
    }
    
    func searchURLByUUID(uuid: String) async throws -> String {
        
        guard let url = URL(string: "http://\(bigModel.ipAdress):8287/api/radio/getURLByUUID/\(uuid)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        guard let resultString = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }

        return resultString
    }
    
    public func deleteProgram(programID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "http://\(bigModel.ipAdress):8287/api/radio/deleteProgram/programId/\(programID)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }.resume()
    }
    
}
