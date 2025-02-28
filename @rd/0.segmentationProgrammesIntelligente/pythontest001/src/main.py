import tensorflow_hub as hub
import librosa
from scipy.spatial.distance import cosine

def format_timestamps(timestamps):
    return [f"{int(t // 60)}:{int(t % 60):02d}" for t in timestamps]

def detect_transitions(file_path, threshold=0.5, hop_size=1.0):
    # Charger l'audio
    audio, sr = librosa.load(file_path, sr=16000, mono=True)  # VGGish attend un échantillonnage à 16 kHz

    # Charger le modèle VGGish depuis TensorFlow Hub
    module_url = "https://tfhub.dev/google/vggish/1"
    vggish_model = hub.load(module_url)

    # Extraire les embeddings audio
    embeddings = vggish_model(audio)

    # Calculer les distances cosinus entre les embeddings successifs
    distances = [
        cosine(embeddings[i], embeddings[i + 1]) for i in range(len(embeddings) - 1)
    ]

    # Identifier les transitions basées sur le seuil
    transition_indices = [i for i, d in enumerate(distances) if d > threshold]
    transition_timestamps = [i * hop_size for i in transition_indices]  # Temps associé aux transitions

    formatted_transitions = format_timestamps(transition_timestamps)
    #print(formatted_transitions)

    print(f"Detected {len(transition_timestamps)} transitions at: {formatted_transitions}")
    return transition_timestamps

# Exemple d'utilisation
if __name__ == "__main__":
    audio_file = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/@rd/0.segmentationProgrammesIntelligente/assets/entrainement-frinter-long.wav"  # Remplacez par votre fichier
    transitions = detect_transitions(audio_file, threshold=0.5)


