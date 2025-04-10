import tensorflow as tf
import tensorflow_hub as hub
import librosa
import numpy as np
from datetime import timedelta

# Chemin de ton fichier
audio_path = "/Users/eglantine/Dev/0.perso/2.Proutechos/8.RadioStreaming/@rd/0.segmentationProgrammesIntelligente/assets/France-inter-jingle-long.mp3"

# Charger YAMNet
yamnet_model = hub.load('https://tfhub.dev/google/yamnet/1')

# Charger les labels AudioSet
import urllib.request
labels_url = 'https://raw.githubusercontent.com/tensorflow/models/master/research/audioset/yamnet/yamnet_class_map.csv'
labels_path = tf.keras.utils.get_file('yamnet_class_map.csv', labels_url)
class_names = [line.strip().split(',')[2] for line in open(labels_path).readlines()[1:]]

# Charger l'audio en mono, 16kHz
waveform, sr = librosa.load(audio_path, sr=16000, mono=True)
print(f"✅ Audio chargé ({len(waveform)/sr:.2f} secondes)")

# Appliquer YAMNet
scores, embeddings, spectrogram = yamnet_model(waveform)
scores_np = scores.numpy()

# Index de la classe "Music"
music_index = class_names.index("Music")
threshold = 0.1  # seuil pour dire "cette frame contient de la musique"
frame_duration = 0.96  # durée d'une frame YAMNet

# Détection de la musique par seuil
music_frames = []
for i, score in enumerate(scores_np):
    if score[music_index] > threshold:
        start = i * frame_duration
        end = start + frame_duration
        music_frames.append((start, end))

# Regrouper les frames consécutives (tolérance de 0.5s)
merged_segments = []
if music_frames:
    current_start, current_end = music_frames[0]
    for start, end in music_frames[1:]:
        if start <= current_end + 0.5:
            current_end = end
        else:
            merged_segments.append((current_start, current_end))
            current_start, current_end = start, end
    merged_segments.append((current_start, current_end))

# Affichage des segments
print("\n🎵 Segments détectés comme musique (seuil > 0.1) :\n")
for i, (start, end) in enumerate(merged_segments):
    t1 = str(timedelta(seconds=int(start)))
    t2 = str(timedelta(seconds=int(end)))
    print(f"{i+1:02d}. {t1} --> {t2} ({end - start:.2f} sec)")

