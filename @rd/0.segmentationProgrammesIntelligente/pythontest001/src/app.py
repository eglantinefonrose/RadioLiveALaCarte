from flask import Flask, jsonify, request
import whisper
import re

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

app = Flask(__name__)

@app.route('/timestamps', methods=['GET'])
def get_timestamps():
    output_name = request.args.get('output_name', '')
    timestamps = find_timestamps(output_name)
    return jsonify(timestamps)

if __name__ == '__main__':
    app.run(debug=True)

