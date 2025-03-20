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

def download_audio(url, output_path='audio.mp3'):
    """
    Télécharge un fichier audio depuis une URL et l'enregistre localement.

    :param url: URL du fichier audio.
    :param output_path: Chemin du fichier de sortie.
    """
    response = requests.get(url, stream=True)

    if response.status_code == 200:
        with open(output_path, 'wb') as audio_file:
            for chunk in response.iter_content(chunk_size=1024):
                if chunk:
                    audio_file.write(chunk)
        print(f"Fichier audio téléchargé avec succès : {output_path}")
    else:
        print(f"Erreur lors du téléchargement. Code HTTP : {response.status_code}")

def transcribe_audio(audio_path):
    model = whisper.load_model("small")
    result = model.transcribe(audio_path)
    print(result['text'])
    return result['text']

# Classe keyword extractor
# 1 qui utilise le modèle sur HuggingFace (actuelle)
# 2 qui utilise un LLM pour lui demander d'extraire des mots clés

def main(video_url):
    #video_path = 'video.mp4'
    audio_path = 'audio.mp3'

    # Download the video
    #download_video(video_url, video_path)

    # Extract audio from the video
    #extract_audio(video_path, audio_path)
    download_audio('https://files.audiomeans.fr/YWRzdjI/062c9e09-3b77-48a6-94f8-36c71f0bc49e/e1a3fb49-a8ca-4eb5-a675-aae4a3fc9c08.mp3?pid=7e38d1d9-513b-4ec6-9fb4-623e0006dfb0&sid=1e757f18-4385-42de-a2eb-f8ee21effa6d&e=062c9e09-3b77-48a6-94f8-36c71f0bc49e&o1=16008&o2=28028634&li=883df78a-5f51-4244-8530-dd037c6347dc&uakey=AEYeFFIPIq&bot=15&pfid=&ps=&cs=&o3=29123&ap=29124-509777&std=a&aid=883df78a-5f51-4244-8530-dd037c6347dc&at=v&astd=a4&ac=RVVSOjE1&rt=1742489111533&crid=&epts=0&xamzn=Root%3D1-67dc46b0-16418f953450f68433669713&xapsi=&cbua=0&pai=&orng=&ims=&Expires=1742575665&Key-Pair-Id=APKAI4ZX6Q3KJ6I76RQA&Signature=VjUXKcZ37SU-p870cn7ur1tAky7OqGY~YBsPzQFtSnhQSeQhTjc-S9scMqJrA0dU6DLogZLNw2cFC8oySBe~jl9GqupucIqgi3Rm6Dg3zJdzcZ~6iO3AQU~OCM6CwkmjfzaKi08Yu85J14tRYz4H9cpe1U1vA-snfR6eOs8httoe-GQ2j9v1nTDCHLF7zivmoYHUo~bwQ5eEBILOBP0lSM9COOEGFPhNSEJnfhuNY90~J94G-ZV~~0JnVeMRN7aKQdm48mFLSs9ihp0cOSUAMq5CcVY4gQUscyhP0-nCDC60mtA062syfyOS~f~t2iRjLczxObp1kuufhw2ntQwt9g__', output_path='audio.mp3')

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
    Donne moi une réponse structurée en JSON, sous la forme suivante :
    {
        "mots_cles_video": ["...", "..."],
        "mots_cles_sujet": ["...", "...", "..."]
    }
    """)
    keyphrases = extractor_llm_based.extract_keywords(text)
    print(keyphrases)

# Example usage
video_url = 'https://media-hub.ina.fr/video/FX2qHyT1cs80A6MYTUFQLyZufFZ/hl3Ww+TydvrCUf44DXd/nBj5A8M2ExDP0Kd04fTjAJBu2FGHVZQ6AKkYdMEAy5ipWVVE+BYUa95UMRZgla1iVuavkiwGZc8t4vRhySFNQaKsF8sTv1I64yy/2Q==/sl_iv/QD+4g/Dm8yqwue0mJ4w8Gg==/sl_hm/QypS76elrNTiKS9bOAE2xtsGkdG11Vs4++5ocCQR4QTpWKb5pQQIdKFgD9qG5NYL3JlJUolo9zBR2OSTJQH7ZA==/sl_e/1743597232'
video_url_test2 = 'https://www.youtube.com/watch?v=glQEPrdHbj8'
main(video_url_test2)
