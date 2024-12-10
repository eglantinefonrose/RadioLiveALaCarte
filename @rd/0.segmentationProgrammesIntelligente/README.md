
# Segmentation Intelligente Programmes Radio

## Objectifs

Détecter l'horaire réel de début et de fin d'un programme radio pris au milieu d'un ensemble d'autres programmes. On peut parler de :
- Segmentation temporelle des programmes radio
- Détection des bornes temporelles dans les émissions radio
- Repérage des segments de contenu radio
- Identification des transitions de programmes radio

## Objectif global

L'objectif de cette partie de *Recherche et Développement* est de régler le soucis du **décalage temporel imprévisible** des programmes radio. Par exemple, une émission radio prévue de **7h à 8h** peut être réellement diffusée de **7h05 à 8h07**. Comme l'utilisateur souhaite écouter le programme dans son **horaire réel**, il faut trouver une solution à ce problème *d'imprévu temporel* qui est la **détection des horaires réels d'une émission**. Pour ce faire, nous utilisons dans ce projet de R&D de l'**intelligence artificielle** pour la détection de **début** et **fin** d'un programme.

## Première approche - Décembre 2024

### Généralités

Dans une première approche, je vais tenter d'utiliser un modèle d'**IA** pour détecter le *début* (souvent marqué par un **jingle**, un **changement de voix**, une **prise de parole après un silence**...) et la *fin* d'un programme radio (souvent marqué par un **jingle**, un **long silence**...). 

### Intégration de la détection d'horaire réelle à l'enregistrement

Pour détecter l'*horaire réelle dans les enregistrements*, je vais utiliser une approche **hybride**.

> Prenons l'exemple d'un programme qui **est annoncé** (par la radio) commencer à **7h** et se terminer à **8h**.
>
> *Nb : Pour cet exemple, nous allons nous concentrer sur le cas d'un enregistrement **non-live**.*
> - L'enregistrement par *ffmpeg* d'un **fichier MP3** de **7h** à **8h10** (on prend une *marge de 10min* afin d'anticiper les possibles *décalages temporels* et prendre l'intégralité de l'émission).
> - Pendant l'enregistrement, le modèle d'IA **analyse le flux audio en parallèle** pour détecter le **début** et la **fin** et stocker les **timestamps correspondants**.
> - À la **fin de l'enregistrement**, le **fichier MP3** enregistré par ffmpeg (enregistrement du flux de *7h* à *8h10*) est **cropé par l'IA** en utilisant les **timestamps** stockés précédement.
>
> - Avec cette approche *en parallèle*, le temps *d'enregistrement + crop* est réduit et si jamais les time-stamps donnés par l'IA semblent *absurdes*, il reste un *enregistrement complet de l'emission* (avec des bouts en trop, dus à la marge et/ou le décalage temporel imprevu).

### Solutions techniques utilisées



## Experimentations en Python

### Projet pythontest001

#### VirtualEnv Python
```bash
# Activation du VirtualEnv
source ./env/bin/activate
# Instalation des dependences (si besoin)
pip install -r requirements.txt
# Mise à jour du fichier requirements.txt
pip freeze > requirements.txt
```

#### Execution du code
```bash
python ./src/main.py
```

