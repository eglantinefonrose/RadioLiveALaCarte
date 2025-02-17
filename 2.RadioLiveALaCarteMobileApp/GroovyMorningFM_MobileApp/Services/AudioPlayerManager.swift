//
//  AudioPlayerManager.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 11/02/2025.
//

import AVFoundation

// Daniel Morin : 6h56 à 7h

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    var audioPlayer: AVAudioPlayer?
    private var fetchTimer: Timer?
    
    @Published var isPlaying: Bool = false
    var wasPaused: Bool = false
    @Published var index: Int = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1
    var recordName: RecordName
    var baseName: String

    override init() {
        
        let programName = APIService.getFirstProgram(for: "user001").id
        print(programName)
        baseName = RecordName.fetchRecordName(for: programName).output_name
        recordName = RecordName(withSegments: 0, output_name: "")
        print(baseName)
        
        super.init()
        
        if (recordName.withSegments == 0) {
            setupTimers(repet: false)
            fetchNonLiveAudio()
        } else {
            setupTimers(repet: true)
            fetchAndReplaceAudio()
        }
        
    }

    private func setupTimers(repet: Bool) {
        // Timer pour mettre à jour currentTime chaque seconde
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }

        if (repet) {
            // Timer pour récupérer un nouvel audio toutes les 5 secondes
            fetchTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                self?.fetchAndReplaceAudio()
            }
        }
        
    }
    
    func fetchBaseName() {
        
        print(APIService.fetchPrograms(for: "user001"))
        
    }
    
    @objc func fetchNonLiveAudio() {
        
        let urlString = "http://localhost:8287/media/mp3/\(baseName)"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Erreur lors du téléchargement de l'audio: \(error)")
                return
            }
            guard let data = data else {
                print("Données invalides pour l'audio")
                return
            }

            DispatchQueue.main.async { [self] in
                
                do {
                    
                    let previousTime = 0 // Récupérer le timeCode actuel
                    
                    let newAudioPlayer = try AVAudioPlayer(data: data)
                    newAudioPlayer.delegate = self
                    newAudioPlayer.prepareToPlay()
                    newAudioPlayer.currentTime = min(TimeInterval(previousTime), newAudioPlayer.duration)  // Assurer la continuité
                    
                    self?.audioPlayer = newAudioPlayer  // Remplacer par le nouveau
                    
                    self?.duration = newAudioPlayer.duration  // Mettre à jour la durée
                    self?.currentTime = newAudioPlayer.currentTime  // Mettre à jour le temps actuel
                    
                } catch {
                    print("Erreur lors du chargement du nouvel audio: \(error)")
                }
                
            }
        }
        task.resume()
        
    }

    @objc func fetchAndReplaceAudio() {
        let urlString = "http://localhost:8287/api/radio/concateneFile/baseName/\(baseName)"
        
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Erreur lors de la récupération de l'index: \(error)")
                return
            }
            guard let data = data, let index = Int(String(data: data, encoding: .utf8) ?? "") else {
                print("Données invalides")
                return
            }
            DispatchQueue.main.async {
                print(urlString)
                self?.index = index
                self?.loadNewAudio(baseName: self!.baseName)
            }
        }
        task.resume()
    }

    func loadNewAudio(baseName: String) {
        let urlString = "http://localhost:8287/media/mp3/concatenated_output\(baseName)output_\(index).mp3"
        print("Chargement de l'audio \(urlString)")

        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Erreur lors du téléchargement de l'audio: \(error)")
                return
            }
            guard let data = data else {
                print("Données invalides pour l'audio")
                return
            }

            DispatchQueue.main.async {
                self?.replaceCurrentAudio(data: data)
            }
        }
        task.resume()
    }

    private func replaceCurrentAudio(data: Data) {
        do {
            let previousTime = (audioPlayer?.currentTime ?? 0) + 0.5  // Récupérer le timeCode actuel
            
            let newAudioPlayer = try AVAudioPlayer(data: data)
            newAudioPlayer.delegate = self
            newAudioPlayer.prepareToPlay()
            newAudioPlayer.currentTime = min(previousTime, newAudioPlayer.duration)  // Assurer la continuité
            
            self.audioPlayer?.stop()  // Stopper l'ancien fichier
            self.audioPlayer = newAudioPlayer  // Remplacer par le nouveau
            
            if (!wasPaused) {
                self.isPlaying = true
                newAudioPlayer.play()
            }
            self.duration = newAudioPlayer.duration  // Mettre à jour la durée
            self.currentTime = newAudioPlayer.currentTime  // Mettre à jour le temps actuel
            
        } catch {
            print("Erreur lors du chargement du nouvel audio: \(error)")
        }
    }
    
    func playPause() {
        if self.isPlaying {
            self.audioPlayer?.pause()
            self.isPlaying = false
            wasPaused = true
        } else {
            self.audioPlayer?.play()
            self.isPlaying = true
            wasPaused = false
        }
    }

    func updateCurrentTime() {
        guard let player = audioPlayer else { return }
        currentTime = player.currentTime
    }

    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = min(time, player.duration)
        currentTime = player.currentTime
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            fetchAndReplaceAudio()
        }
    }
}
