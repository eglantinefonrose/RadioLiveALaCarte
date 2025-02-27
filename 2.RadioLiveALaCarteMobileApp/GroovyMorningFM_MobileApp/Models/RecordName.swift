//
//  RecordNale.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 14/02/2025.
//

import Foundation

class RecordName: Codable, Identifiable {
    
    var withSegments: Int
    var output_name: String
    
    init(withSegments: Int, output_name: String) {
        self.withSegments = withSegments
        self.output_name = output_name
    }
    
    static func fetchRecordName(for programId: String) -> RecordName {
        let urlString = "http://\(BigModel.shared.ipAdress):8287/api/radio/getSuitableFileNameByProgramId/programId/\(programId)"
        print("http://\(BigModel.shared.ipAdress)/api/radio/getSuitableFileNameByProgramId/programId/\(programId)")
        guard let url = URL(string: urlString) else {
            return RecordName(withSegments: 0, output_name: "")
        }
        
        var recordName: RecordName = RecordName(withSegments: 0, output_name: "")
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
                recordName = try JSONDecoder().decode(RecordName.self, from: data)
                print(recordName.output_name)
            } catch {
                print("Erreur de décodage :", error.localizedDescription)
            }
        }.resume()
        
        semaphore.wait()
        return recordName
    }
    
}
