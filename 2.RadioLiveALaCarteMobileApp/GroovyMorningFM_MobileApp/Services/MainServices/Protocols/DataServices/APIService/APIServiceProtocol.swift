//
//  APIServiceProtocol.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 18/04/2025.
//

import Foundation

protocol APIServiceProtocol {
    func validerHoraire(
        radioName: String,
        startTimeHour: Int,
        startTimeMinute: Int,
        startTimeSeconds: Int,
        endTimeHour: Int,
        endTimeMinute: Int,
        endTimeSeconds: Int,
        completion: @escaping (Result<String, Error>) -> Void
    )
    
    func createProgram(
        radioName: String,
        startTimeHour: Int,
        startTimeMinute: Int,
        startTimeSeconds: Int,
        endTimeHour: Int,
        endTimeMinute: Int,
        endTimeSeconds: Int,
        radioUUID: String
    ) async throws -> String

    func creerHoraireDanielMorin()

    func fetchPrograms(for userId: String) async -> [Program]

    func getFirstProgram(for userId: String) async -> Program

    static func fetchFilesWithoutSegmentNames(for userId: String, completion: @escaping ([String]) -> Void)

    func searchByName(for name: String, completion: @escaping (LightenedRadioStationAndAmountOfResponses) -> Void)
    
    func searchByUUID(uuid: String) async throws -> String

    func deleteProgram(programID: String, completion: @escaping (Result<Void, Error>) -> Void)
}
