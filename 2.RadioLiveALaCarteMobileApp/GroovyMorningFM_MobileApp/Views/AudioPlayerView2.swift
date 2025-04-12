import SwiftUI

struct AudioPlayerView2: View {
    
    @StateObject private var audioManager = AudioPlayer2215(danielMorin: true)
    
    @State private var programs: [Program] = []
    private let userId = "user001"
    @ObservedObject var apiService: APIService = APIService()
    @ObservedObject var bigModel: BigModel = BigModel.shared
    @State private var showPopup: Bool = false
    @State var ipAddress: String = ""
    
    @State private var offsetY: CGFloat = UIScreen.main.bounds.height / 2
    let minHeight: CGFloat = UIScreen.main.bounds.height / 2
    let maxHeight: CGFloat = UIScreen.main.bounds.height - 100
    
    @State var disliked: Bool = false
    @State var liked: Bool = false
    
    var body: some View {
        
        ZStack {
                        
            VStack(spacing: 20) {
                
                HStack {
                    Text("Back")
                        .bold()
                        .foregroundStyle(Color.blue)
                        .padding(10)
                        .onTapGesture {
                            if (bigModel.viewHistoryList.count >= 2) {
                                bigModel.currentView = bigModel.viewHistoryList[bigModel.viewHistoryList.count-2]
                            }
                        }
                    
                    Spacer()
                    Image(systemName: "person.circle")
                        .padding(10)
                    Image(systemName: "gear")
                        .padding(10)
                        .onTapGesture {
                            bigModel.currentView = .IpAdressView
                        }
                }
                
                Toggle("Show trimmed audios", isOn: $bigModel.raw)
                    .bold()
                    .padding(20)
                
                Image("400x400_sc_le-billet-de-daniel-morin")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                
                VStack {
                                        
                    if (audioManager.areThereAnyAudiosAvailable()) {
                        
                        // Barre de progression du temps de lecture
                        Slider(value: $audioManager.currentTime, in: 0...audioManager.duration, onEditingChanged: { isEditing in
                            if !isEditing {
                                audioManager.seek(to: audioManager.currentTime)
                            }
                        })
                        .padding()
                        
                        // Affichage du temps écoulé et de la durée totale
                        HStack {
                            Text(formatTime(audioManager.currentTime)) // Temps actuel
                            Spacer()
                            Text(formatTime(audioManager.duration)) // Durée totale
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                        
                        // Boutons de contrôle
                        HStack() {
                            
                            Button(action: {
                                audioManager.seek(to: max(audioManager.currentTime - 10, 0)) // Retour de 10 secondes
                            }) {
                                Image(systemName: "gobackward.10")
                                    .foregroundColor(.white)
                                    .font(.title)
                            }
                            
                            Image(systemName: disliked ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .foregroundColor(.white)
                                .onTapGesture {
                                    
                                    if (!disliked) {
                                        if (liked) {
                                            audioManager.deleteFeedback { result in
                                                switch result {
                                                    case .success(let message):
                                                        print("Succès :", message)
                                                        liked.toggle()
                                                    audioManager.giveFeedback(feedback: "Bad") { result in
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
                                            audioManager.giveFeedback(feedback: "Bad") { result in
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
                                        audioManager.deleteFeedback { result in
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
                                .foregroundColor(.white)
                                .onTapGesture {
                                    audioManager.previousTrack()
                                }
                            
                            Button(action: {
                                audioManager.playPause()
                            }) {
                                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            
                            Image(systemName: "forward.end.fill")
                                .foregroundColor(.white)
                                .onTapGesture {
                                    audioManager.nextTrack()
                                }
                            
                            /*Image(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .foregroundColor(.white)
                                .onTapGesture {
                                    audioManager.giveFeedback(feedback: "Good") { result in
                                        switch result {
                                            case .success(let message):
                                                print("Succès :", message)
                                                liked.toggle()
                                                if (disliked) {
                                                    disliked.toggle()
                                                }
                                            case .failure(let error):
                                                print("Erreur :", error.localizedDescription)
                                        }
                                    }
                                }*/
                            
                            Image(systemName: liked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .foregroundColor(.white)
                                .onTapGesture {
                                    
                                    if (!liked) {
                                        if (disliked) {
                                            audioManager.deleteFeedback { result in
                                                switch result {
                                                    case .success(let message):
                                                        print("Succès :", message)
                                                        disliked.toggle()
                                                        audioManager.giveFeedback(feedback: "Good") { result in
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
                                            audioManager.giveFeedback(feedback: "Good") { result in
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
                                        audioManager.deleteFeedback { result in
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
                            
                            Button(action: {
                                audioManager.seek(to: min(audioManager.currentTime + 10, audioManager.duration)) // Avance de 10 secondes
                            }) {
                                Image(systemName: "goforward.10")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        
                    } else {
                        Text("No programs are available today")
                    }
                    
                }
                
                HStack {
                    Text("Programmer l'enregistrement de Daniel Morin pour demain (7:57 - 8:00)")
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 25)
                }.background(Color.white)
                    .cornerRadius(10)
                    .onTapGesture {
                        APIService.shared.creerHoraireDanielMorin()
                    }
                
                Spacer()
            }
            .padding()
            
            //BottomSheetView(audioManager: audioManager, offsetY: $offsetY, minHeight: minHeight, maxHeight: maxHeight, programs: bigModel.programs)
            
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color(red: 203/255, green: 43/255, blue: 57/255))
        .onChange(of: bigModel.ipAdress) { oldId, newIp in
            Task {
                let fetchedPrograms = await apiService.fetchPrograms(for: userId)
                self.programs = fetchedPrograms
                bigModel.programs = fetchedPrograms
            }
        }
        .onChange(of: bigModel.raw) { oldValue, newValue in
            audioManager.loadAndPlay()
        }
        .onChange(of: bigModel.programs) { oldValue, newValue in
            audioManager.getFeedback { result in
                switch result {
                case .success(let feedback):
                    if feedback == "Bad" {
                        disliked = true
                    }
                    if feedback == "Good" {
                        liked = true
                    }
                    print("Feedback reçu : \(feedback)")
                case .failure(let error):
                    print("Erreur : \(error.localizedDescription)")
                }
            }
        }
        
        .onAppear {
            
            BigModel.shared.danielMorinVersion = true
            if bigModel.ipAdress == "" {
                showPopup = true
            } else {
                Task {
                    let fetchedPrograms = await apiService.fetchPrograms(for: userId)
                    self.programs = fetchedPrograms
                    bigModel.programs = fetchedPrograms
                }
            }
            
        }
        
    }
    
    // Fonction pour formater le temps en mm:ss
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}

#Preview {
    AudioPlayerViewDanielMorin()
}


