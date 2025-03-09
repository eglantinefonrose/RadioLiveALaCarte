from flask import Flask, jsonify, request
import whisper
import re
import tensorflow_hub as hub
import librosa
import numpy as np
from scipy.spatial.distance import cosine

#
#
# Version Daniel Morin
#
#
def chaine_contient_sous_chaine(chaine, sous_chaine):
    # Supprimer la ponctuation et convertir en minuscules
    chaine_nettoyee = re.sub(r'[^\w\s]', '', chaine).lower()
    sous_chaine_nettoyee = re.sub(r'[^\w\s]', '', sous_chaine).lower()

    # Vérifier si la sous-chaîne est contenue dans la chaîne
    return sous_chaine_nettoyee in chaine_nettoyee

def trouver_indices_segments(result, search_term):
    premier_indice = None
    dernier_indice = None

    for index, segment in enumerate(result["segments"]):
        text = segment["text"].lower()
        if chaine_contient_sous_chaine(text, search_term):
            if premier_indice is None:
                premier_indice = index
            dernier_indice = index

    return premier_indice, dernier_indice

def format_timestamps(t):
    return f"{int(t // 60)}:{int(t % 60):02d}"

def find_timestamps(output_name: str):
    # Charger le modèle Whisper
    model = whisper.load_model("small")

    # Charger et transcrire l'audio avec timestamps
    audio_path = output_name
    result = model.transcribe(audio_path, word_timestamps=True)

    # Afficher la transcription complète avec timestamps
    #print("\n--- Transcription complète ---\n")
    for segment in result["segments"]:
        start_time = segment["start"]
        end_time = segment["end"]
        text = segment["text"]
        #print(f"[{start_time:.2f} - {end_time:.2f}] {text}")

    search_term = "Daniel Morin"

    # Chercher le bout de phrase dans la transcription
    print("\n--- Recherche du bout de phrase ---\n")
    found = False

    search_term = "daniel morin"

    premier_indice, dernier_indice = trouver_indices_segments(result, search_term)

    if (premier_indice and dernier_indice) is not None:
        if dernier_indice+1 != result["segments"]:
            premier_segment = result["segments"][premier_indice]
            start_time = premier_segment["start"]

            dernier_segment = result["segments"][dernier_indice+1]
            if dernier_indice+1 is not None:
                end_time = dernier_segment["start"]
            else:
                end_time = dernier_segment[-1]

            return [start_time, end_time]
    else:
        print("Le terme de recherche n'a pas été trouvé.")
        premier_segment = result["segments"][0]
        start_time = premier_segment["start"]
        dernier_segment = result["segments"][-1]
        end_time = dernier_segment["end"]
        print(start_time)
        print(end_time)
        return [start_time, end_time]


#
#
# Version classique
#
#

def format_timestamps(timestamps):
    return [f"{int(t // 60)}:{int(t % 60):02d}" for t in timestamps]

def closest_duration(timestamps, assumedDuration, startTime):
    if not timestamps or len(timestamps) < 2:
        return [0, assumedDuration]  # Pas assez de timestamps pour faire une paire

    timestamps.sort()  # Trier les timestamps
    start_time = timestamps[0] + startTime  # Horaire de début présumé

    best_t1, best_t2 = 0, assumedDuration
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

    return (best_t1, best_t2) if best_t1 != 0 else [0, assumedDuration]

def detect_transitions(output_name: str):
    # Charger l'audio
    threshold = 0.5
    hop_size = 1.0
    audio, sr = librosa.load(output_name, sr=16000, mono=True)  # VGGish attend un échantillonnage à 16 kHz
    assumedDuration = len(audio) / sr

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

    assumedDuration = 199
    startTime = 44

    result = closest_duration(transition_timestamps, assumedDuration, 30)
    print(format_timestamps(result))

    print(f"Detected {len(transition_timestamps)} transitions at: {formatted_transitions}")
    return result

app = Flask(__name__)

@app.route('/getTimestampsDanielMorin', methods=['GET'])
def get_timestamps():
    output_name = request.args.get('output_name', '')
    timestamps = find_timestamps(output_name)
    return jsonify(timestamps)

@app.route('/getTimestamps', methods=['GET'])
def get_transitions():
    output_name = request.args.get('output_name', '')
    timestamps = detect_transitions(output_name)
    return jsonify(timestamps)

if __name__ == '__main__':
    app.run(debug=True)

