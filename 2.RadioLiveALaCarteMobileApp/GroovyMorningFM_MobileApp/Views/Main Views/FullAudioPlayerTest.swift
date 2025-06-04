import Foundation
import SwiftUI
import FFmpegSupport
import AVFoundation
import Combine
import Speech

struct AudioSegment {
    let url: URL
    let duration: Double
    var transcription: String?
}

class AudioPlayerManager952025: ObservableObject {
    
    @Published var duration: Double = 0
    @Published var currentTime: Double = 0
    @Published var isPlaying: Bool = true

    private var player = AVQueuePlayer()
    private var timeObserver: Any?
    private var timer: Timer?
    
    private var segments: [AudioSegment] = []
    private var itemSegmentMap: [AVPlayerItem: AudioSegment] = [:]
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    //let filePrefix: String
    var keywordFound: Bool = false
    
    var firstPlay: Bool = true
    
    //
    //
    // SINGLETON
    //
    //
    
    static private(set) var shared: AudioPlayerManager952025!
    
    init(filePrefix: String) {
        BigModel.shared.isAnAudioSelected = true
        startMonitoring(filePrefix: filePrefix)
        observeTime()
        
        // Demande de permission au lancement
        SFSpeechRecognizer.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Autorisé")
            case .denied, .restricted, .notDetermined:
                print("Transcription non autorisée")
            @unknown default:
                break
            }
        }
    }
    
    static func configure(filePrefix: String) {
        guard shared == nil else {
            print("MonManager est déjà configuré.")
            return
        }
        shared = AudioPlayerManager952025(filePrefix: filePrefix)
    }

    deinit {
        timer?.invalidate()
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
    }

    private func observeTime() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.updateGlobalCurrentTime()
        }
    }

    private func updateGlobalCurrentTime() {
        guard let currentItem = player.currentItem else { return }

        let currentSegment = itemSegmentMap[currentItem]
        let index = segments.firstIndex { $0.url == currentSegment?.url } ?? 0

        let previousDurations = segments.prefix(index).map { $0.duration }.reduce(0, +)
        let currentItemTime = player.currentTime().seconds

        currentTime = previousDurations + currentItemTime
    }

    func startMonitoring(filePrefix: String) {
        loadSegments(filePrefix: filePrefix)
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.loadSegments(filePrefix: filePrefix)
        }
        player.play()
    }
    
    private func loadSegments(filePrefix: String) {
        let files = try? FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
        let newFiles = (files ?? [])
            .filter { $0.lastPathComponent.hasPrefix(filePrefix) && $0.pathExtension == "mp4" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        let alreadyLoadedURLs = Set(segments.map { $0.url })
        let filesToAdd = newFiles.filter { !alreadyLoadedURLs.contains($0) }

        var pendingSegments: [(url: URL, asset: AVURLAsset)] = []

        for fileURL in filesToAdd {
            let asset = AVURLAsset(url: fileURL)
            pendingSegments.append((url: fileURL, asset: asset))
        }

        guard !pendingSegments.isEmpty else { return }

        let group = DispatchGroup()
        var loadedSegments: [AudioSegment] = []

        for (url, asset) in pendingSegments {
            group.enter()
            asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                var error: NSError?
                let status = asset.statusOfValue(forKey: "duration", error: &error)
                if status == .loaded {
                    let duration = asset.duration.seconds
                    let segment = AudioSegment(url: url, duration: duration, transcription: nil)
                    loadedSegments.append(segment)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let sortedSegments = loadedSegments.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
            self.processSegmentsSequentially(sortedSegments)
            
        }
    }

    private func processSegmentsSequentially(_ segments: [AudioSegment], index: Int = 0, foundTrigger: Bool = false) {
        guard index < segments.count else {
            self.updateTotalDuration()
            return
        }

        let segment = segments[index]

        // Si la condition a été déclenchée précédemment, on ajoute immédiatement sans transcription
        if foundTrigger {
            keywordFound = true
            let item = AVPlayerItem(url: segment.url)
            self.player.insert(item, after: nil)
            self.segments.append(segment)
            self.itemSegmentMap[item] = segment
            self.processSegmentsSequentially(segments, index: index + 1, foundTrigger: true)
            return
        }

        // Sinon on transcrit normalement
        
        if (keywordFound) {
            
            let item = AVPlayerItem(url: segment.url)
            self.player.insert(item, after: nil)
            self.segments.append(segment)
            self.itemSegmentMap[item] = segment
            self.processSegmentsSequentially(segments, index: index + 1, foundTrigger: true)
            
        } else {
            
            TranscriptionService.shared.transcrireAudioDepuisFichier(fileURL: segment.url) { result in
                var triggerFound = foundTrigger
                switch result {
                case .success(let transcription):
                    print("✅ Transcription réussie : \(transcription)")

                    if transcription.localizedStandardContains("image") {
                        let item = AVPlayerItem(url: segment.url)
                        self.player.insert(item, after: nil)
                        self.segments.append(segment)
                        self.itemSegmentMap[item] = segment
                        triggerFound = true
                    } else {
                        do {
                            try FileManager.default.removeItem(at: segment.url)
                            print("🗑️ Fichier supprimé : \(segment.url.lastPathComponent)")
                        } catch {
                            print("⚠️ Erreur lors de la suppression du fichier : \(error.localizedDescription)")
                        }
                    }

                case .failure(let error):
                    print("❌ Erreur lors de la transcription : \(error.localizedDescription)")
                }

                // Traitement du suivant
                self.processSegmentsSequentially(segments, index: index + 1, foundTrigger: triggerFound)
            }
            
        }
        
    }


    private func updateTotalDuration() {
        duration = segments.map { $0.duration }.reduce(0, +)
    }
    
    func videLesSegments() {
        player.pause() // facultatif, mais souvent recommandé
        player.removeAllItems()
        segments.removeAll()
        itemSegmentMap.removeAll()
        currentTime = 0
        duration = 0
    }

    func seek(to globalTime: Double) {
        guard !segments.isEmpty else { return }

        var accumulated = 0.0
        var targetIndex: Int?
        var timeInSegment: Double = 0

        for (index, segment) in segments.enumerated() {
            let nextAccumulated = accumulated + segment.duration
            if globalTime < nextAccumulated {
                targetIndex = index
                timeInSegment = globalTime - accumulated
                break
            }
            accumulated = nextAccumulated
        }

        guard let index = targetIndex else { return }

        let newPlayer = AVQueuePlayer()
        let remainingSegments = segments[index...]

        for segment in remainingSegments {
            let item = AVPlayerItem(url: segment.url)
            newPlayer.insert(item, after: nil)
            itemSegmentMap[item] = segment
        }

        player.pause()
        player = newPlayer
        observeTime()

        newPlayer.currentItem?.seek(to: CMTime(seconds: timeInSegment, preferredTimescale: 600), completionHandler: { [weak self] _ in
            newPlayer.play()
            self?.player = newPlayer
        })
    }

    func togglePlayPause() {
        
        if self.isPlaying {
            player.pause()
            BigModel.shared.isPlaying = false
            isPlaying = false
            return
        } else {
            player.play()
            BigModel.shared.isPlaying = true
            isPlaying = true
            return
        }

        /*if !self.isPlaying {
            if firstPlay {
                loadSegments()
                firstPlay = false
                isPlaying = true
                return
            } else {
                player.play()
                isPlaying = true
                return
            }
        }*/
    }
    
}



extension UIImage {
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 10
        let height = 10
        
        // Redimensionner l'image à 10x10 pour simplifier l'analyse
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
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context.data else { return nil }

        let ptr = data.bindMemory(to: UInt8.self, capacity: width * height * 4)
        var colorCount: [UInt32: Int] = [:]

        for x in 0..<width {
            for y in 0..<height {
                let offset = 4 * (y * width + x)
                let r = ptr[offset]
                let g = ptr[offset + 1]
                let b = ptr[offset + 2]
                let a = ptr[offset + 3]
                
                guard a > 0 else { continue } // Ignorer pixels transparents

                let colorKey = (UInt32(r) << 24) | (UInt32(g) << 16) | (UInt32(b) << 8) | UInt32(a)
                colorCount[colorKey, default: 0] += 1
            }
        }

        // Trouver la couleur la plus fréquente
        if let (dominantKey, _) = colorCount.max(by: { $0.value < $1.value }) {
            let r = CGFloat((dominantKey >> 24) & 0xFF) / 255.0
            let g = CGFloat((dominantKey >> 16) & 0xFF) / 255.0
            let b = CGFloat((dominantKey >> 8) & 0xFF) / 255.0
            let a = CGFloat(dominantKey & 0xFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }

        return nil
    }
}

extension Color {
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjustBrightness(by: -abs(percentage))
    }

    private func adjustBrightness(by percentage: CGFloat) -> Color {
        // Convert Color to UIColor
        let uiColor = UIColor(self)

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = max(min(brightness + (percentage / 100.0), 1.0), 0.0)
            return Color(hue: Double(hue), saturation: Double(saturation), brightness: Double(newBrightness), opacity: Double(alpha))
        }

        return self // fallback
    }
    
    func isCloserToWhite() -> Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Calcul de la luminance perçue (standard sRGB)
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        return luminance > 0.5 // Plus proche du blanc si > 0.5
    }
    
}




struct FullAudioPlayerTest: View {
    
    let filesPrefixs: [String] = BigModel.shared.liveProgramsNames
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @State var playing: Bool = true
    
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height / 2
    let minHeight: CGFloat = UIScreen.main.bounds.height / 2
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    
    @State var disliked: Bool = false
    @State var liked: Bool = false
    
    @State var backgroundColor: Color = Color.gray
    
    @StateObject private var manager: AudioPlayerManager952025 = AudioPlayerManager952025.shared
            
    var body: some View {
        ZStack {
            
            bigModel.playerBackgroudColor
                .ignoresSafeArea()
            
            VStack {
                
                Image(systemName: "house")
                    .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                    .onTapGesture {
                        bigModel.currentView = .ProgramScreen
                    }
                
                Spacer()
                
                
                if (!manager.keywordFound) {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1)
                            .padding()
                            .foregroundStyle(Color.purple)
                        Spacer()
                    }.padding()
                } else {
                    VStack {
                        
                        AsyncImage(url: URL(string: bigModel.programs[bigModel.currentProgramIndex].favIcoURL)) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            bigModel.extractDominantColor(from: image)
                                        }
                                    }
                            } else {
                                ProgressView()
                            }
                        }.padding()
                        
                        Text("\(formatTime(manager.currentTime)) / \(formatTime(manager.duration))")
                            .font(.headline)
                            .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white)
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Track
                                Rectangle()
                                    .foregroundColor(.gray.opacity(0.3))
                                    .frame(height: 4)
                                
                                // Filled track
                                Rectangle()
                                    .foregroundColor(.blue)
                                    .frame(width: CGFloat(manager.currentTime / manager.duration) * geo.size.width, height: 4)
                                
                                // Thumb (optionnel)
                                Circle()
                                    .foregroundColor(.white)
                                    .frame(width: 12, height: 12)
                                    .offset(x: CGFloat(manager.currentTime / manager.duration) * geo.size.width - 6)
                            }
                            .contentShape(Rectangle()) // Permet de détecter les tap même en dehors du trait fin
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let ratio = min(max(0, value.location.x / geo.size.width), 1)
                                        let newVal = ratio * manager.duration
                                        manager.seek(to: newVal)
                                    }
                            )
                        }
                        .frame(height: 20)
                        .padding()
                        
                    }
                    .onChange(of: playing) { oldValue, newValue in
                        manager.togglePlayPause()
                    }
                    .onChange(of: bigModel.currentProgramIndex) { oldValue, newValue in
                        manager.videLesSegments()
                        manager.startMonitoring(filePrefix: "\(filesPrefixs[bigModel.currentProgramIndex])_")
                        if (!playing) {
                            playing = true
                        }
                    }
                }
                
                HStack {
                    
                    Image(systemName: disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                        .foregroundColor(.white)
                        .onTapGesture {
                            
                            if (!disliked) {
                                if (liked) {
                                    bigModel.deleteFeedback { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            liked.toggle()
                                            bigModel.giveFeedback(feedback: "Bad") { result in
                                                switch result {
                                                case .success(let message):
                                                    print("Succès :", message)
                                                    disliked.toggle()
                                                case .failure(let error):
                                                    print("Erreur :", error.localizedDescription)
                                                }
                                            }
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                } else {
                                    bigModel.giveFeedback(feedback: "Bad") { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            disliked.toggle()
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                }
                            } else {
                                bigModel.deleteFeedback { result in
                                    switch result {
                                    case .success(let message):
                                        print("Succès :", message)
                                        liked.toggle()
                                    case .failure(let error):
                                        print("Erreur :", error.localizedDescription)
                                    }
                                }
                            }
                            
                        }
                    
                    Image(systemName: "backward.end.fill")
                        .font(.title)
                        .disabled(bigModel.currentProgramIndex == 0)
                        .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white)
                        .onTapGesture {
                            if bigModel.currentProgramIndex > 0 {
                                bigModel.currentProgramIndex -= 1
                            } else if !bigModel.delayedProgramsNames.isEmpty {
                                bigModel.currentView = .MultipleAudiosPlayer
                            }
                        }
                    
                    Button(action: {
                        playing.toggle()
                    }) {
                        Image(systemName: bigModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                    }
                    
                    Button(action: {
                        if bigModel.currentProgramIndex < filesPrefixs.count - 1 {
                            bigModel.currentProgramIndex += 1
                        }
                    }) {
                        Image(systemName: "forward.end.fill")
                            .font(.title)
                            .foregroundStyle(bigModel.playerBackgroudColor.isCloserToWhite() ? Color.black : Color.white.darker(by: 10))
                    }
                    .disabled(bigModel.currentProgramIndex == filesPrefixs.count - 1)
                    
                    Image(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                        .foregroundColor(.white)
                        .onTapGesture {
                            
                            if (!liked) {
                                if (disliked) {
                                    bigModel.deleteFeedback { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            disliked.toggle()
                                            bigModel.giveFeedback(feedback: "Good") { result in
                                                switch result {
                                                case .success(let message):
                                                    print("Succès :", message)
                                                    liked.toggle()
                                                case .failure(let error):
                                                    print("Erreur :", error.localizedDescription)
                                                }
                                            }
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                } else {
                                    bigModel.giveFeedback(feedback: "Good") { result in
                                        switch result {
                                        case .success(let message):
                                            print("Succès :", message)
                                            liked.toggle()
                                        case .failure(let error):
                                            print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                }
                            } else {
                                bigModel.deleteFeedback { result in
                                    switch result {
                                    case .success(let message):
                                        print("Succès :", message)
                                        liked.toggle()
                                    case .failure(let error):
                                        print("Erreur :", error.localizedDescription)
                                    }
                                }
                            }
                            
                        }
                    
                }
                .padding()
                
                Spacer()
            }
            
            BottomSheetView(offsetY: $offsetY, minHeight: minHeight, maxHeight: maxHeight, programs: bigModel.programs)
        }.onAppear {
            
            bigModel.getFeedback { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let feedback):
                        if feedback == "Good" {
                            liked = true
                            disliked = false
                        }
                        if feedback == "Bad" {
                            liked = false
                            disliked = true
                        }
                    case .failure(let error):
                        print("Erreur lors du chargement")
                        print(error.localizedDescription)
                    }
                }
            }
            
        }
        .onChange(of: bigModel.currentProgramIndex) { _ in
            // On change de programme => on télécharge et extrait la couleur
            let urlString = bigModel.programs[bigModel.currentProgramIndex].favIcoURL
            if let url = URL(string: urlString) {
                // Charge l'image (ici un AsyncImage ferait la même chose, mais pour la démo, on peut charger manuellement)
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, let uiImage = UIImage(data: data) else { return }
                    let swiftUIImage = Image(uiImage: uiImage)
                    Task { @MainActor in
                        bigModel.extractDominantColor(from: swiftUIImage)
                    }
                }
                task.resume()
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let intSec = Int(seconds)
        let minutes = intSec / 60
        let secs = intSec % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
    
}


