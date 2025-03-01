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

def trouver_indices_segments(result, search_term):
    """
    Trouve les indices du premier et du dernier segment où le terme de recherche est trouvé.

    Args:
        result: Le résultat contenant les segments.
        search_term: Le terme de recherche.

    Returns:
        Un tuple contenant l'indice du premier segment trouvé et l'indice du dernier segment trouvé,
        ou (None, None) si le terme de recherche n'est pas trouvé.
    """
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

def find_timestamps():
    # Charger le modèle Whisper
    model = whisper.load_model("small")

    # Charger et transcrire l'audio avec timestamps
    audio_path = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/@rd/0.segmentationProgrammesIntelligente/assets/DANIEL_MORIN_test1.mp3"
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

    if premier_indice is not None:
        if dernier_indice+1 != result["segments"]:
            premier_segment = result["segments"][premier_indice]
            start_time = premier_segment["start"]

            dernier_segment = result["segments"][dernier_indice+1]
            if dernier_indice+1 is not None:
                end_time = dernier_segment["start"]
            else:
                end_time = dernier_segment[-1]

            #print(f"Le terme de recherche a été trouvé pour la première fois à {start_time} et pour la dernière fois à {end_time}.")
            return [start_time, end_time]
    else:
        print("Le terme de recherche n'a pas été trouvé.")
        premier_segment = result["segments"][0]
        start_time = premier_segment["start"]
        dernier_segment = result["segments"][-1]
        end_time = dernier_segment["end"]
        return [start_time, end_time]