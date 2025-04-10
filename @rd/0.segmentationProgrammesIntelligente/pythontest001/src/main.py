import tensorflow_hub as hub
import librosa
from scipy.spatial.distance import cosine
from mutagen.mp3 import MP3

def format_timestamps(timestamps):
    return [f"{int(t // 60)}:{int(t % 60):02d}" for t in timestamps]

def closest_duration(timestamps, assumedDuration, startTime):
    if not timestamps or len(timestamps) < 2:
        return [0, assumedDuration]  # Pas assez de timestamps pour faire une paire

    timestamps.sort()  # Trier les timestamps
    start_time = timestamps[0] + startTime  # Horaire de début présumé

    best_t1, best_t2 = 0, 0
    min_diff = float('inf')

    for i in range(len(timestamps) - 1):
        if timestamps[i] < start_time:
            continue  # Ignorer les timestamps avant start_time

        for j in range(i + 1, len(timestamps)):
            duration = timestamps[j] - timestamps[i]

            if duration >= assumedDuration:
                diff = duration - assumedDuration
                if diff < min_diff:
                    min_diff = diff
                    best_t1, best_t2 = timestamps[i], timestamps[j]

                break  # Une fois qu'on a trouvé un écart valide, on arrête la boucle j

    return [best_t1, best_t2] if best_t1 != 0 else [0, assumedDuration]

def detect_transitions(file_path, threshold=0.5, hop_size=1.0):
    # Charger l'audio
    audio, sr = librosa.load(file_path, sr=16000, mono=True)  # VGGish attend un échantillonnage à 16 kHz
    assumedDuration = len(audio) / sr
    #audio = MP3(file_path)

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

    startTime = 44

    result = closest_duration(transition_timestamps, assumedDuration, 30)
    #print(format_timestamps(result))

    #print(f"Detected {len(transition_timestamps)} transitions at: {formatted_transitions}")
    return result

# Exemple d'utilisation
if __name__ == "__main__":
    audio_file = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/@rd/0.segmentationProgrammesIntelligente/assets/France-inter-jingle-long.mp3"  # Remplacez par votre fichier
    print(detect_transitions(audio_file, threshold=0.3))

#"http://127.0.0.1:5000/getTimestampsDanielMorin?output_name=/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioLiveALaCarteServer/app/src/main/resources/static/media/mp3/output_83220994-2616-4fd2-96e8-0d10965704c8_11490.mp3"  # Remplacez par votre fichier

