import whisper
import datetime

# Charger le modèle Whisper (medium ou large si tu veux plus de précision)
model = whisper.load_model("medium")  # ou "small" pour aller plus vite

# Transcrire le fichier audio
result = model.transcribe("/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/@rd/0.segmentationProgrammesIntelligente/assets/DANIEL_MORIN_test1.mp3", verbose=False)

# Parcourir les segments pour trouver les timecodes
segments = result['segments']

DEBUT_KEYWORDS = ["Merci"]
FIN_KEYWORDS = ["Merci"]

debut, fin = None, None

for seg in segments:
    text = seg['text'].lower()
    if not debut and any(k.lower() in text for k in DEBUT_KEYWORDS):
        debut = seg['start']
    if any(k.lower() in text for k in FIN_KEYWORDS):
        fin = seg['end']

print(f"Début de l'émission estimé à : {debut:.2f} sec")
print(f"Fin de l'émission estimée à : {fin:.2f} sec")
