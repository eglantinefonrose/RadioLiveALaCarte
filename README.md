# RADIO LIVE A LA CARTE

## Objectifs
- Permettre à des utilisateurs d'écouter les chroniques 

## Etapes du projet
- Je dois commencer telle chronique à telle heure
- Savoir à quelle heure commence réellement la chronique
- Permettre à l'utilisateur d'écouter la radio en live

## Player

- Le player permet de <strong>naviguer</strong> entre les <strong>programmes</strong> sélectionnées au préalable par l'utilisateur.
- Les <strong>programmes</strong> correspondent à une <strong>plage horaire</strong> d'une <strong>radio spécifique</strong>, informations qui sont toutes les deux <strong>choisies par l'utilisateur</strong>.
- Si jamais une émission est en <strong>cours de diffusion</strong>, il est possible de <strong>l'écouter</strong>, cependant l'émission aura un <strong>retard de 10 sec</strong> dû à l'utilisation de <strong>segments</strong> de 10 secondes chacuns.

## Généralités sur l'interface

- À la manière d'une <strong>playlist</strong> sur une application de musique, l'utilisateur a une vision sur les <strong>programmes disponibles à l'écoute</strong> et voit le programme qu'il est entrain d'écouter s'afficher en <strong>gras</strong>.

[Demo_1_InterfaceGlobale_RadioLiveALaCarte.mov](@docs/assets/Demo_1_RadioLiveALaCarte.mov)

## Création de programme pour l'utilisateur

- À ce stade de la création de l'application, l'utilisateur a le monopole sur les décisions sur les plages horaires des programmes qu'il souhaite écouter. L'interface lui permet donc de sélectionner la radio qu'il souhaite écouter aux horaires (voir vidéo).

[Demo_2_CreationDeProgramme_RadioLiveALaCarte.mov](@docs/assets/RadioLiveALaCarte-Demo-ProgramCreation.mov)

- NB : Dans l'idéal, l'utilisateur souhaiterait également pouvoir accéder au programme réel des émissions des radios qu'il souhaiterait écouter.

## Détails techniques

- Dans un cas *réaliste*, les programmes radios sont souvent **décalés dans le temps** à cause des **imprévus possibles** (accumulation de retards des émissions précédentes d'une taille variable par exemple).
Afin de régler ce soucis, j'ai commencé une phase de *Recherche et Développement* qui utilise des **modèles d'IA** pour détecter le début et la fin *réelle* d'un programme radio.  
Cette partie est disponible dans la branche [RD_BRANCH_IdentificationIntelligenteTransitionsEntreProgrammesRadio](https://github.com/eglantinefonrose/RadioLiveALaCarte/tree/RD_BRANCH_IdentificationIntelligenteTransitionsEntreProgrammesRadio) :)



