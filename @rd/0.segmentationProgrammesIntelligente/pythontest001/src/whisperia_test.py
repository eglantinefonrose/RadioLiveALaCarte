import whisper
import re

def chaine_contient_sous_chaine(chaine, sous_chaine):
    """
    Vérifie si une chaîne contient une sous-chaîne, en ignorant la casse et la ponctuation.

    Args:
        chaine: La chaîne principale.
        sous_chaine: La sous-chaîne à rechercher.

    Returns:
        True si la sous-chaîne est trouvée, False sinon.
    """
    # Supprimer la ponctuation et convertir en minuscules
    chaine_nettoyee = re.sub(r'[^\w\s]', '', chaine).lower()
    sous_chaine_nettoyee = re.sub(r'[^\w\s]', '', sous_chaine).lower()

    # Vérifier si la sous-chaîne est contenue dans la chaîne
    return sous_chaine_nettoyee in chaine_nettoyee

def format_timestamps(t):
    return f"{int(t // 60)}:{int(t % 60):02d}"

def trouver_indices_segments(result, search_term):
    premier_indice = None
    dernier_indice = None

    for i, segment in enumerate(result["segments"]):
        if search_term.lower() in segment["text"].lower():
            if premier_indice is None:
                premier_indice = i
            dernier_indice = i

    return premier_indice, dernier_indice


def find_timestamps():
    # Charger le modèle Whisper
    model = whisper.load_model("small")

    # Charger et transcrire l'audio avec timestamps
    audio_path = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/0.RadioLiveALaCarteServer/app/src/main/resources/static/media/mp3/output_3b748f74-2d3a-41aa-afe4-aeee4b4465d9_6570.mp3"
    result = model.transcribe(audio_path, word_timestamps=True)

    # Recherche des mots clés
    for search_term in ["daniel morin", "daniel", "morin"]:
        premier_indice, dernier_indice = trouver_indices_segments(result, search_term)

        if premier_indice is not None:
            premier_segment = result["segments"][premier_indice]
            start_time = premier_segment["start"]

            if dernier_indice + 1 < len(result["segments"]) and dernier_indice != premier_indice:
                dernier_segment = result["segments"][dernier_indice + 1]
                end_time = dernier_segment["start"]
            else:
                dernier_segment = result["segments"][-1]
                end_time = dernier_segment["end"]

            return [start_time, end_time]

    # Aucun mot clé trouvé
    print("Le terme de recherche n'a pas été trouvé.")
    premier_segment = result["segments"][0]
    start_time = premier_segment["start"]
    dernier_segment = result["segments"][-1]
    end_time = dernier_segment["end"]
    return [start_time, end_time]

print(find_timestamps())

