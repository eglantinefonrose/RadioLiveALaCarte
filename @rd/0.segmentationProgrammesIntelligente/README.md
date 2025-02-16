
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

> Prenons l'exemple d'un programme qui **est annoncé** (par la radio) commencer à **7h05** et se terminer à **7h15**.
>
> *Nb : Pour cet exemple, nous allons nous concentrer sur le cas d'un enregistrement **non-live**.*
> - L'enregistrement par *ffmpeg* d'un **fichier MP3** de **7h05** à **7h25** (on prend une *marge de 10min* afin d'anticiper les possibles *décalages temporels* et prendre l'intégralité de l'émission).
> - Pendant l'enregistrement, le modèle d'IA **analyse le flux audio en parallèle** pour détecter le **début** et la **fin** et stocker les **timestamps correspondants**.
> - À la **fin de l'enregistrement**, le **fichier MP3** enregistré par ffmpeg (enregistrement du flux de *7h05* à *7h25*) est **cropé par l'IA** en utilisant les **timestamps** stockés précédement.
>
> - Avec cette approche *en parallèle*, le temps *d'enregistrement + crop* est réduit et si jamais les time-stamps donnés par l'IA semblent *absurdes*, il reste un *enregistrement complet de l'emission* (avec des bouts en trop, dus à la marge et/ou le décalage temporel imprevu).

## Solutions techniques

### Utilisation du modèle d'IA VGGISH pour détecter les transitions

Dans cette *première tentative* de détection des débuts et fins d'émissions radios, j’utilise le modèle d’IA **VVGISH** comme un **outil** dans la **détection des transitions** entre les programmes.

https://github.com/tensorflow/models/blob/master/research/audioset/vggish/README.md

#### 1. Traiter le signal

Cette IA **découpe** l'audio entrant en très courtes **segments** (synonyme : **fenêtre temporelle**) pour transformer par la suite chaque segment en un objet mathématique, un **embedding**.

>
> Un **embedding** est une *représentation numérique* d'un objet (comme un mot, une phrase ou un segment d'audio) en un *vecteur* (objet mathématique) avec un *nombre de dimensions élevé* (par exemple, 256, 512, ou 1024 dimensions), contenant une **multitude d’informations** compressées sur les **propriétés des objets**.  
*Exemple* : Dans notre cas, l’objet est un **signal vidéo**, les propriétés compressées peuvent donc être les *propriétés perceptuelles du son*, des informations sur les *hauteurs des notes*…).

#### 2. Trouver les transitions

Une fois l'**audio** transformé en une multitude d'**embeddings** (vecteurs), on calcule les **distances** entre les vecteurs pour en déduire si s'agit d'une **transition** ou non.
> Nb : Pour identifier si il y a une **transition** entre dans l'audio, on  compare deux **embeddings consécutifs**. En calculant la **distance** entre ces deux objets, on peut savoir si ils sont **très différents** ou non (donc si les **propriétés** de deux **segments audios** sont très différentes). Dans le cas où la **distance** entre deux objets est **très grande**, on considère qu'il y a une **transition** entre les **deux segments consécutifs**.  

*Commnent évaluer à partir de quand la distance est jugée **suffisament grande** pour marquer une **transition** ?*  
> Pour évaluer la *distance minimale* pour marquer une *transition*, on établit un **seuil** (*threshold*) que la distance doit **dépasser**.

Compte-tenu de la **faible longueur** des segments (**0.96 sec**) (définie dans les paramètres du modèle dans le fichier *'vggish_pca_params.npz'*), on considère la détection d'une **transition entre deux segments** comme un **point temporel**.

On ne considère donc pas de **points temporels** de *début* ou de *fin*, mais uniquement des **points de transitions entre deux programmes** (un point temporel correspond à la *fin* du programme précédent le point temporel, et au *début* du programme suivant le point temporel).

<br/><img src='assets/schema-explicatif-transition.png'/><br/>

> En bref, l'utilisation de la **transformation en objets** permettant la **comparaison de segments audios** entre eux et leur comparaison permet de **détecter les points de transition** entre les programmes, et donc de **trouver le début et la fin** de chacuns.   


### Détecter les bonnes transitions

Cette première solution permet de *détecter les transitions*, mais il ne semble pas exister de **seuil universel** (seuil de distance entre deux embeddings) qui détecte les bonnes transitions **pour toutes les pistes audios**.  

Pour un seuil **trop bas**, **plus de 2 transitions** sont detectés.

À contrario, si on **augmente le seuil** pour qu'il ne détecte que 2 transtions, il n'est pas dit que le programme **détecte les bonnes transitions**, à cause de facteurs comme un **silence trop long dans une prise de parole**, qui peut **s'apparenter à une transition**.

> Le soucis est donc de réussir à détecter les **transitions réelles** entre les programmes, avec comme impératif de ne **pas raccourcir le programme radio**.

#### 1. Ne pas raccourcir le programme radio

Afin de ne jamais raccourcir le programme radio, il faut que si la **différence temporelle** entre deux transitions est **inférieure à la durée suposée du programme**, l'enregistrement audio d'entrée **n'est pas raccourci**.

#### 2. Détecter les bonnes transitions

Pour réaliser cela, plusieurs solutions sont appliquables :
- **Trouver la différence de temps entre deux transitions la plus proche de la durée présumée du programme** 

Cela consiste à **parcourir le tableau** contenant tous les **timecodes des transitions**, afin de trouver la **différence temporelle la plus proche** (et supérieure) à la **durée présumée** du programme.

> **Exemple d'enregistrement d'un programme A qui dure 3min30**
> 
> *Tableau de transitions detectés*  
> ```python
> [0:10; 0:12; 0:25; 1:33; 1:34; 1:35; 3:45; 3:55; 4:10]
> ```
> Dans ce tableau, l'écart entre les transitions à **0:25 et 3:55 correspond parfaitement à 3min30**.  
> Le soucis, c'est que ce ne sont pas les **réelles transitions** de ce programme qui sont à **0:10** et **3:55**.

Dans ce cas de figure, le programme serait alors **raccourci** et il serait **impossible de savoir que ce ne sont pas les bonnes transitions**. 

*Sécurité pour palier à ce problème :*  
Afin d'**éviter de raccourcir le programme visé**, une solution peut-être de considérer la transition **précédent la transition de début** et la transition **suivant la transition de fin**. Bien que cette sécurité ne soit pas **fiable à 100%**, elle peut permettre déjà d'éviter de raccourcir la **majorité des programmes**.

- **Transitions succéssives**

En observant les **transitions detectées selon différentes émissions**, on constate que au moment des **jingles**, il y a souvent **des transitions successives**.

> Exemple des transitions avec un jingle
> - Premier jingle de **0:25 à 0:29**
> - Second jingle de **3:30 à 3:39**
> 
> Voilà les time-codes transitions détectées par le programme :
> ```python
> [00:00:23, 00:00:24, 00:00:24, 00:00:30, 00:01:05, 00:01:06, 00:02:26, 00:03:17, 00:03:18, 00:03:29, 00:03:30, 00:03:49, 00:04:13]
> ```
> 



```java

class RealStartAndEndForProgram {
    public int startTimecode;
    public int endTimecode;
} 

class RealStartAndEndForProgramFinder {
    
    public RealStartAndEndForProgram findRealStartAndEndForProgram(int[] timeCodesFoundByAIModel, int theoriticalProgramDurationInSec) {
        ...
    }
    
}

```