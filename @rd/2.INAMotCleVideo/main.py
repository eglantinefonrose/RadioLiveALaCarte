import requests
from pytube import YouTube
from moviepy.editor import VideoFileClip
import whisper

from keywordsextractor_keyphrase_extraction_kbir_inspec import KeyphraseExtractionPipeline
from keywordsextractor_LLMBasedKeywordsExtractor import LLMBasedKeywordsExtractor

def download_video(url, output_path='video.mp4'):
    # Vérifier si c'est une URL de Youtube
    if "youtube.com" in url or "youtu.be" in url:
        # Crée un objet YouTube (en utilisant la librairie YouTube de pytube) à partir de l'URL
        # Les objets YouTube permettent d'accéder aux différents formats et qualités de téléchargement disponibles (streams).
        yt = YouTube(url)
        # Filtrer les flux de la vidéo pour choisir le format MP4
        stream = yt.streams.filter(file_extension='mp4').first()
        # Télécharge la première vidéo correspondant aux critères et la sauvegarde dans le dossier du projet sous video.mp4
        stream.download(filename=output_path)
    else:
        # Effectue une requête HTTP GET pour récupérer le contenu
        response = requests.get(url)
        # Ouvre un fichier en mode écriture binaire ('wb')
        # Enregistre le contenu de la réponse HTTP
        # f correspond au fichier ouvert
        with open(output_path, 'wb') as f:
            # Écrit les données de response dans le fichier ouvert
            f.write(response.content)

def extract_audio(video_path, audio_path='audio.mp3'):
    # Charger un fichier vidéo sous forme d’objet manipulable en Python.
    video = VideoFileClip(video_path)
    video.audio.write_audiofile(audio_path)

def transcribe_audio(audio_path):
    model = whisper.load_model("small")
    result = model.transcribe(audio_path)
    return result['text']

# Classe keyword extractor
# 1 qui utilise le modèle sur HuggingFace (actuelle)
# 2 qui utilise un LLM pour lui demander d'extraire des mots clés

def main(video_url):
    video_path = 'video.mp4'
    audio_path = 'audio.mp3'

    # Download the video
    download_video(video_url, video_path)

    # Extract audio from the video
    extract_audio(video_path, audio_path)

    # Transcribe audio to text
    text = transcribe_audio(audio_path)
    #print(text)

    # Using model keyphrase-extraction-kbir-inspec to extract keywords
    print(" ------- Using model keyphrase-extraction-kbir-inspec to extract keywords -------")
    model_name = "ml6team/keyphrase-extraction-kbir-inspec"
    extractor = KeyphraseExtractionPipeline(model=model_name)
    keyphrases = extractor(text)
    print(keyphrases)

    # Using an LLM with a custom prompt to extract keywords
    print(" ------- Using an LLM with a custom prompt to extract keywords -------")
    extractor_llm_based = LLMBasedKeywordsExtractor(custom_prompt="""
    Dans le texte suivant, extrait deux types de mots-clés :
       - 2 mots-clés sur le type de vidéo (Séries et fictions, documentaires, spectacles et concerts, émissions...)
       - 3 mots clés sur le sujet traité
    Donne moi une réponse structurée en JSON, sous la forme suivante :
    {
        "mots_cles_video": ["...", "..."],
        "mots_cles_sujet": ["...", "...", "..."]
    }
    """)
    #keyphrases = extractor_llm_based.extract_keywords(text)
    #print(keyphrases)

# Example usage
video_url = 'https://media-hub.ina.fr/video/FX2qHyT1cs80A6MYTUFQLyZufFZ/hl3Ww+TydvrCUf44DXd/nBj5A8M2ExDP0Kd04fTjAJBu2FGHVZQ6AKkYdMEAy5ipWVVE+BYUa95UMRZgla1iVuavkiwGZc8t4vRhySFNQaKsF8sTv1I64yy/2Q==/sl_iv/QD+4g/Dm8yqwue0mJ4w8Gg==/sl_hm/QypS76elrNTiKS9bOAE2xtsGkdG11Vs4++5ocCQR4QTpWKb5pQQIdKFgD9qG5NYL3JlJUolo9zBR2OSTJQH7ZA==/sl_e/1743597232'
main(video_url)
