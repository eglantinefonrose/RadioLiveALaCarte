//
//  APIService.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 29/01/2025.
//

import Foundation

class APIService: ObservableObject {
    
    static let shared = APIService()
    
    /*func validerHoraire(radioName: String, startTimeHour: Int, startTimeMinute: Int, startTimeSeconds: Int, endTimeHour: Int, endTimeMinute: Int, endTimeSeconds: Int) {
        
        let urlString = "http://localhost:8287/api/radio/createAndRecordProgram/radioName/\(radioName)/startTimeHour/\(startTimeHour)/startTimeMinute/\(startTimeHour)/startTimeSeconds/\(startTimeSeconds)/endTimeHour/\(endTimeHour)/endTimeMinute/\(endTimeMinute)/endTimeSeconds/\(endTimeSeconds)/userID/user001"
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
    }*/
    
    func validerHoraire(
        radioName: String,
        startTimeHour: Int,
        startTimeMinute: Int,
        startTimeSeconds: Int,
        endTimeHour: Int,
        endTimeMinute: Int,
        endTimeSeconds: Int,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Construction correcte de l'URL
        let urlString = "http://localhost:8287/api/radio/createAndRecordProgram/radioName/\(radioName)/startTimeHour/\(startTimeHour)/startTimeMinute/\(startTimeMinute)/startTimeSeconds/\(startTimeSeconds)/endTimeHour/\(endTimeHour)/endTimeMinute/\(endTimeMinute)/endTimeSeconds/\(endTimeSeconds)/userID/user001"
        
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
    
    func creerHoraireDanielMorin() {
        let urlString = "http://localhost:8287/api/radio/createAndRecordProgram/radioName/FranceInter/startTimeHour/12/startTimeMinute/0/startTimeSeconds/0/endTimeHour/12/endTimeMinute/5/endTimeSeconds/0/userID/user001"
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
    
    static func fetchPrograms(for userId: String) -> [Program] {
        let urlString = "http://localhost:8287/api/radio/getProgramsByUser/userId/\(userId)"
        guard let url = URL(string: urlString) else {
            return []
        }
        
        var programs: [Program] = []
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }
            if let error = error {
                print("Erreur :", error.localizedDescription)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                programs = try JSONDecoder().decode([Program].self, from: data)
            } catch {
                print("Erreur de décodage :", error.localizedDescription)
            }
        }.resume()
        
        semaphore.wait()
        return programs
    }
    
    static func getFirstProgram(for userId: String) -> Program {
        let programs: [Program] = self.fetchPrograms(for: userId)
        
        if (programs.isEmpty) {
            return Program(id: "", radioName: "", startTimeHour: 0, startTimeMinute: 0, startTimeSeconds: 0, endTimeHour: 0, endTimeMinute: 0, endTimeSeconds: 0, favIcoURL: "")
        }
        
        return programs[0]
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
    
    static func searchByName(for name: String, completion: @escaping (LightenedRadioStationAndAmountOfResponses) -> Void) {
        
        let urlString = "http://localhost:8287/api/radio/lightenSearchByName/\(name)"
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
    
}
