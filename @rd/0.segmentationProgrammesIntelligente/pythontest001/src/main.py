import tensorflow_hub as hub
import librosa
import numpy as np
from scipy.spatial.distance import cosine

def detect_transitions(file_path, threshold=0.5, hop_size=1.0):
    # Charger l'audio
    audio, sr = librosa.load(file_path, sr=16000, mono=True)  # VGGish attend un échantillonnage à 16 kHz

    # Charger le modèle VGGish depuis TensorFlow Hub
    module_url = "https://tfhub.dev/google/vggish/1"
    vggish_model = hub.load(module_url)

    # Extraire les embeddings audio
    embeddings = vggish_model(audio[np.newaxis, :])

    # Calculer les distances cosinus entre les embeddings successifs
    distances = [
        cosine(embeddings[i], embeddings[i + 1]) for i in range(len(embeddings) - 1)
    ]

    # Identifier les transitions basées sur le seuil
    transition_indices = [i for i, d in enumerate(distances) if d > threshold]
    transition_timestamps = [i * hop_size for i in transition_indices]  # Temps associé aux transitions

    print(f"Detected {len(transition_timestamps)} transitions at: {transition_timestamps}")
    return transition_timestamps


# Exemple d'utilisation
if __name__ == "__main__":
    audio_file = "/Users/eglantine/Desktop/entrainement-frinter-long.wav"  # Remplacez par votre fichier
    transitions = detect_transitions(audio_file, threshold=0.5)



