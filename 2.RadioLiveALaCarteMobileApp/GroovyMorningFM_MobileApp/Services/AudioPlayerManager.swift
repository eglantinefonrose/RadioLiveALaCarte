//
//  AudioPlayerManager.swift
//  GroovyMorningFM_MobileApp
//
//  Created by Eglantine Fonrose on 11/02/2025.
//

import AVFoundation
import Combine

// Daniel Morin : 6h56 à 7h

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    
    var audioPlayer: AVAudioPlayer?
    
    @Published var isPlaying: Bool = false
    var wasPaused: Bool = false
    @Published var index: Int = 0
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 1
    var recordName: RecordName = RecordName(withSegments: 0, output_name: "")
    var baseName: String = ""
    
    var versionDanielMorin: Bool
    
    private var liveBaseNames: [String] = []
    private var liveBaseNameIndex: Int = 0
    private var asLiveJustStarted: Bool = true
    
    var isFirstAudioPlayed: Bool = false
    @Published var isLivePlaying: Bool = false
    var username: String = ""
    
    private var updateTimer: Timer?
    private var fetchTimer: Timer?
    
    var apiService: APIService = APIService.shared
    let bigModel: BigModel = BigModel.shared
    
    private var audioURLs: [URL] = []
    
    public func setAudioURLs(urls: [URL]) {
        audioURLs = urls
    }
    
    public func setUserName(username: String) {
        self.username = username
    }
    
    public func areThereAnyAudiosAvailable() -> Bool {
        return !(audioURLs.isEmpty && liveBaseNames.isEmpty)
    }
    
    init(danielMorin: Bool) {
        self.versionDanielMorin = danielMorin
        super.init() // Appel à l'initialisation de la classe mère
        
        setupTimers(repet: false)
        fetchAllURLs()
        
    }
    
    override init() {
        self.versionDanielMorin = false // Valeur par défaut
        super.init()
        
        setupTimers(repet: false)
        fetchAllURLs()
        
        if !self.audioURLs.isEmpty {
            loadAudio(at: bigModel.currentProgramIndex)
            self.setupTimers(repet: false)
        } else if !self.liveBaseNames.isEmpty {
            setupTimers(repet: true)
            self.fetchAndReplaceAudio()
            print("With segments : \(self.recordName.output_name)")
        }
    
    }

    
    public func updateCurrentProgramIndex(index: Int) {
                
        if (bigModel.currentProgramIndex < audioURLs.count) {
            self.bigModel.currentProgramIndex = index
            loadAudio(at: bigModel.currentProgramIndex)
        } else {
            
            if ( ((bigModel.currentProgramIndex - audioURLs.count)) < liveBaseNames.count) {
                if (!isLivePlaying) {
                    // Premier audio du live
                    isLivePlaying = true
                } else {
                    bigModel.currentProgramIndex += 1
                }
                
                setupTimers(repet: true)
                fetchAndReplaceAudio()
            }
            
        }
    }
    
    func addTrimmedToFileName(urlString: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        
        // Séparer le nom de fichier et l'extension
        let fileName = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension
        
        // Vérifier que le fichier est bien un .mp3
        guard fileExtension == "mp3" else { return urlString }
        
        // Construire le nouveau nom de fichier
        let newFileName = "\(fileName)-trimmed.\(fileExtension)"
        
        // Remplacer l'ancien nom par le nouveau dans l'URL
        let newUrlString = url.deletingLastPathComponent().appendingPathComponent(newFileName).absoluteString
        
        return newUrlString
    }
    
    /*private func fetchAllURLs() {
        
        if (versionDanielMorin) {
            DispatchQueue.main.async { [self] in
                Task {
                    let fetchedPrograms = await self.apiService.fetchPrograms(for: "user001")
                    self.bigModel.programs = fetchedPrograms
                                        
                    for program in fetchedPrograms {
                        
                        let recordName = RecordName.fetchRecordName(for: program.id)
                        
                        if (recordName.withSegments == 0) {
                            if (recordName.output_name != "") {
                                audioURLs.append(URL(string: "http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")!)
                                print("http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")
                            }
                        } else {
                            let programName = program.id
                            self.recordName = RecordName.fetchRecordName(for: programName)
                            liveBaseNames.append(RecordName.fetchRecordName(for: programName).output_name)
                        }
                        
                    }
                    
                    print("all URls = \(audioURLs)")
                }
            }
        } else {
            
            let fetchedPrograms = self.bigModel.programs
            
            for program in fetchedPrograms {
                
                let recordName = RecordName.fetchRecordName(for: program.id)
                
                if (recordName.withSegments == 0) {
                    if (recordName.output_name != "") {
                        audioURLs.append(URL(string: "http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")!)
                        print("http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")
                    }
                } else {
                    let programName = program.id
                    self.recordName = RecordName.fetchRecordName(for: programName)
                    liveBaseNames.append(RecordName.fetchRecordName(for: programName).output_name)
                }
                
            }
            
            print("all URls = \(audioURLs)")
        }
    }*/
    private func fetchAllURLs() {
            
            if (versionDanielMorin) {
                DispatchQueue.main.async { [self] in
                    Task {
                        let fetchedPrograms = await self.apiService.fetchPrograms(for: "user001")
                        self.bigModel.programs = fetchedPrograms
                                            
                        for program in fetchedPrograms {
                            
                            let recordName = RecordName.fetchRecordName(for: program.id)
                            
                            if (recordName.withSegments == 0) {
                                if (recordName.output_name != "") {
                                    audioURLs.append(URL(string: "http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")!)
                                    print("http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")
                                }
                            } else {
                                let programName = program.id
                                self.recordName = RecordName.fetchRecordName(for: programName)
                                liveBaseNames.append(RecordName.fetchRecordName(for: programName).output_name)
                            }
                            
                        }
                        
                        if !self.audioURLs.isEmpty {
                            loadAudio(at: bigModel.currentProgramIndex)
                            self.setupTimers(repet: false)
                        } else if !self.liveBaseNames.isEmpty {
                            setupTimers(repet: true)
                            self.fetchAndReplaceAudio()
                            print("With segments : \(self.recordName.output_name)")
                        }
                        
                    }
                }
            } else {
                
                let fetchedPrograms = self.bigModel.programs
                
                for program in fetchedPrograms {
                    
                    let recordName = RecordName.fetchRecordName(for: program.id)
                    
                    if (recordName.withSegments == 0) {
                        if (recordName.output_name != "") {
                            audioURLs.append(URL(string: "http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")!)
                            print("http://\(bigModel.ipAdress):8287/media/mp3/\(recordName.output_name).mp3")
                        }
                    } else {
                        let programName = program.id
                        self.recordName = RecordName.fetchRecordName(for: programName)
                        liveBaseNames.append(RecordName.fetchRecordName(for: programName).output_name)
                    }
                    
                }
                
                print("all URls = \(audioURLs)")
            }
        }

    
    private func loadAudio(at index: Int) {
        guard index >= 0, index < audioURLs.count else { return }
        
        let url: URL = bigModel.raw ? URL(string: addTrimmedToFileName(urlString: audioURLs[index].absoluteString)!)! : audioURLs[index]
        
        func fetchAudio(from url: URL, retry: Bool = false) {
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let data = data, error == nil, data.count > 9 { // Vérification sur la taille des données
                    DispatchQueue.main.async {
                        print(data)
                        self.prepareAudio(data: data)
                    }
                } else if bigModel.raw, !retry {
                    fetchAudio(from: audioURLs[index], retry: true)
                } else {
                    print("Erreur de chargement de l'audio: \(error?.localizedDescription ?? "Inconnue") ou données insuffisantes (\(data?.count ?? 0) bytes)")
                }
            }.resume()
        }
            
        fetchAudio(from: url)
    }
    
    private func prepareAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            duration = audioPlayer?.duration ?? 1
            currentTime = 0
            if isPlaying {
                audioPlayer?.play()
            }
        } catch {
            print("Erreur lors de la préparation de l'audio: \(error)")
        }
    }
        
    func nextTrack() {
                
        if (bigModel.currentProgramIndex+1 < audioURLs.count) {
            
            bigModel.currentProgramIndex += 1
            loadAudio(at: bigModel.currentProgramIndex)
            print(bigModel.currentProgramIndex)
            
        } else {
            
            if ((bigModel.currentProgramIndex+1 - audioURLs.count) < liveBaseNames.count) {
                
                bigModel.currentProgramIndex += 1
                asLiveJustStarted = true
                
                if (!isLivePlaying) {
                    // Premier audio du live
                    isLivePlaying = true
                }
                setupTimers(repet: true)
                fetchAndReplaceAudio()
            }
            
        }
        
    }
    
    func previousTrack() {
        
        if (bigModel.currentProgramIndex <= audioURLs.count) {
            
            invalidateTimers()
            isLivePlaying = false
            bigModel.currentProgramIndex -= 1
            loadAudio(at: bigModel.currentProgramIndex)
            
        } else {
            
            if ((bigModel.currentProgramIndex - audioURLs.count) > 0) {
                    
                bigModel.currentProgramIndex -= 1
                asLiveJustStarted = true
                
                setupTimers(repet: true)
                fetchAndReplaceAudio()
                
            } else {
                bigModel.currentProgramIndex -= 1
                isLivePlaying = false
                loadAudio(at: bigModel.currentProgramIndex)
            }
            
        }
        
    }

    private func setupTimers(repet: Bool) {
        // Invalider les anciens timers si existants
        updateTimer?.invalidate()
        fetchTimer?.invalidate()

        // Timer pour mettre à jour currentTime chaque seconde
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCurrentTime()
        }

        if repet {
            // Timer pour récupérer un nouvel audio toutes les 5 secondes
            fetchTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                self?.fetchAndReplaceAudio()
            }
        }
    }
    
    private func invalidateTimers() {
        fetchTimer?.invalidate()
        fetchTimer = nil
    }

    
    func fetchBaseName() async {
        
        await print(apiService.fetchPrograms(for: "user001"))
        
    }
    
    @objc func fetchNonLiveAudio() {
        
        let urlString = "http://\(bigModel.ipAdress):8287/media/mp3/\(audioURLs[index])"
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
                    self?.audioPlayer?.play()
                    
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
        
        print("bigModel.currentProgramIndex+1 - audioURLs.count = \(bigModel.currentProgramIndex+1 - audioURLs.count)")
        print("liveBaseNames.count = \(liveBaseNames.count)")
        let urlString = "http://\(bigModel.ipAdress):8287/api/radio/concateneFile/baseName/\(liveBaseNames[(bigModel.currentProgramIndex - audioURLs.count)])"
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
                
                self?.index = index
                self?.loadNewAudio(baseName: self!.baseName)
            }
            
        }
        task.resume()
        
    }

    func loadNewAudio(baseName: String) {
        let urlString = "http://\(bigModel.ipAdress):8287/media/mp3/concatenated_output\(liveBaseNames[(bigModel.currentProgramIndex - audioURLs.count)])output_\(index).mp3"
        print("Chargement de l'audio livex \(urlString)")

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
            
            if (asLiveJustStarted) {
                newAudioPlayer.currentTime = 0
            } else {
                newAudioPlayer.currentTime = min(previousTime, newAudioPlayer.duration)  // Assurer la continuité
            }
            
            self.audioPlayer?.stop()  // Stopper l'ancien fichier
            self.audioPlayer = newAudioPlayer  // Remplacer par le nouveau
            
            if (!wasPaused) {
                self.isPlaying = true
                newAudioPlayer.play()
            }
            self.duration = newAudioPlayer.duration  // Mettre à jour la durée
            self.currentTime = newAudioPlayer.currentTime  // Mettre à jour le temps actuel
            
            if (asLiveJustStarted) {
                asLiveJustStarted = false
            }
            
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
    
    func loadAndPlay() {
        
        if (!isLivePlaying) {
            loadAudio(at: bigModel.currentProgramIndex)
            print(bigModel.currentProgramIndex)
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
            nextTrack()
        }
    }
}

extension Notification.Name {
    static let ipAddressUpdated = Notification.Name("ipAddressUpdated")
}
