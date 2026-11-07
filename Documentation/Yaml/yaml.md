# 4 - YAML – Introduction

*Révision du 2026.11.07*

<p align="center">
    <img src="../images/yaml-768x769.png" alt="YAML" width="250" />
</p>

### Ah non, pas un autre façon de représenter des structures de données 😉 !

---

## Contenu

- [**Description**](#section-description)
- [**1 – Insérer des commentaires dans un document YAML**](#section-1)
- [**2 – Variables scalaires**](#section-2)
  - [2.1 – Chaines de caractères](#section-2-1)
  - [2.2 – Définition d'une chaine sur plusieurs lignes](#section-2-2)
  - [2.3 – Nombres](#section-2-3)
  - [2.4 – Valeur booléenne](#section-2-4)
  - [2.5 – Valeur 'null'](#section-2-5)
  - [2.6 – Représentation de dates](#section-2-6)
- [**3 – Structures et listes**](#section-3)
  - [3.1 – Une liste (tableau, vecteur) de chaines de caractères](#section-3-1)
  - [3.1c – Exemple d'une structure imbriquée](#section-3-1c)
  - [3.2 – Structures complexes – valeurs imbriquées](#section-3-2)
- [**4 – Les noeuds**](#section-4)
  - [4.1 – Réutilisation d'un noeud](#section-4-1)

---

## Description {#section-description}

**YAML Ain't Markup Language**

**Référence**: [YAML](https://yaml.org/spec/1.2/spec.html)

**Validateur YAML en ligne**: [yamllint](http://www.yamllint.com)

**Convertisseur YAML → JSON**: [onlineyamltools](https://onlineyamltools.com/convert-yaml-to-json)

---

## 1 – Insérer des commentaires dans un document YAML {#section-1}

```yaml
# Je suis un commentaire
# Référence de YAML : https://yaml.org/spec/1.2/spec.html

# Je suis dans la zone des directives YAML
# https://yaml.org/spec/1.2/spec.html#id2781553

# Je (---) délimite les deux zones
---  

# Je suis dans la zone de contenu YAML
```

---

## 2 – Variables scalaires {#section-2}

### 2.1 – Chaines de caractères {#section-2-1}

```yaml
# Une chaine non délimitée
titre: L'Origine des espèces

# Une chaine délimitée
sous-titre: "L'origine des espèces au moyen de la sélection naturelle ou la préservation des races favorisées dans la lutte pour la survie"

# Une chaine multi-lignes débute par le car '|'
especes: |
  mammifère
  oiseau
  reptile
  poisson
```

**2.1b – Représentation JSON**

```json
{
   "titre" :       "L'Origine des espèces",
   "sous-titre" :  "L'origine des espèces au moyen de la sélection naturelle ou la préservation des races favorisées dans la lutte pour la survie",
   "especes" :     "mammifère\noiseau\nreptile\npoisson\n"
}
```

### 2.2 – Définition d'une chaine sur plusieurs lignes {#section-2-2}

```yaml
# Expression sur plusieurs lignes avec un seul \n à la fin de la chaine:
commentaires: >
    Late afternoon is best.
    Backup contact is Nancy
    Billsmer @ 338-4338.
```

**2.2b – JSON**

```json
{ 
   "commentaires": "Late afternoon is best. Backup contact is Nancy Billsmer @ 338-4338.\n"
}
```

### 2.3 – Nombres {#section-2-3}

```yaml
# Définir des nombres:

# Entier:
age: 33

# Nombre flottant  - Float:
PI: 3.1415926535897932384626433832

# Notation scientifique:
population: 7.7947e+9
```

**2.3b – JSON**

```json
{
   "age": 33,
   "PI":  3.141592653589793,
   "population": 7794700000.0
}
```

### 2.4 – Valeur booléenne {#section-2-4}

```yaml
# Valeur booléenne 
important: false
# important: False
# important: FALSE
```

**2.4b – JSON**

```json
{
   "important": false
}
```

### 2.5 – Valeur 'null' {#section-2-5}

```yaml
# Représentation de la valeur 'null'
# Peut être défini par l'absence d'affectation

valeur-null: 

# Ou bien, explicitement:

autre-valeur-null: null

# valeur-null: NULL
# valeur-null: Null
```

**2.5b – JSON**

```json
{
    "valeur-null": null
}
```

### 2.6 – Représentation de dates {#section-2-6}

```yaml
# Représentation des dates et horodatages (timestamps)
date: 2022-02-22
canonical: 2021-01-15T05:59:43.1Z
iso8601: 2011-01-14t11:59:43.10-05:00
avec-espaces: 2021-02-14 23:59:43.10 -5
```

**2.6b – JSON**

```json
{
  "date": "2022-02-22T00:00:00.000Z",
  "canonical": "2021-01-15T05:59:43.100Z",
  "iso8601": "2011-01-14T16:59:43.100Z",
  "avec-espaces": "2021-02-15T04:59:43.100Z"
}
```

---

## 3 – Structures et listes {#section-3}

### 3.1 – Une liste (tableau, vecteur) de chaines de caractères {#section-3-1}

```yaml
# Représentation d'une liste d'éléments
# Définir une liste d'éléments avec '-':
mammifères:
    - chat
    - chien
    - souris

# Version en ligne 'inline':
poissons: [ ange, truite, saumon ]
```

**Exemple un peu plus complexe:**

```yaml
mammifères:
 - chat
 - chien
 - souris: # structure de données
     nom: Mimi
     taille: 5cm
     poids:  5gr
     type:
     - ville: 
       - grisse
       - brune
     - campagne:
       - curieuse: # Élément nul
       - coquine: ["Du matin", "du soir"]
```

**Représentation JSON:**

```json
{
  "mammifères": [
    "chat",
    "chien",
    {
      "souris": {
        "nom": "Mimi",
        "taille": "5cm",
        "poids": "5gr",
        "type": [
          {
            "ville": [
              "grisse",
              "brune"
            ]
          },
          {
            "campagne": [
              {
                "curieuse": null
              },
              {
                "coquine": [
                  "Du matin",
                  "du soir"
                ]
              }
            ]
          }
        ]
      }
    }
  ]
}
```

**Voici un exemple Kubernetes**

```yaml
# -------------------------------------------------------------
# Fichier: exemple1.1.yml
# Auteur: Alain Boudreault
# Projet: 420-4D4-Semaine 10
# Date: 
# -------------------------------------------------------------
# Exemple d'un manifeste pour un Pod nginx avec un emptyDir
# -------------------------------------------------------------
apiVersion: v1
kind: Pod
metadata:
  name: exemple1-1
spec:
  containers:
  - name: nginx
    image: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html  # Ceci est le dossier web de nginx
      name: volume-web

  - name: une-debian
    image: debian
    command: ["sleep", "1000"]
    volumeMounts:
    - mountPath: /petit-coquin
      name: volume-web

  - name: une-alpine
    image: alpine
    command: ['sh', '-c', 'echo "Je suis 420-4D4 ;)-" > /misere/index.html']
    volumeMounts:
    - mountPath: /misere
      name: volume-web
  # restartPolicy: Never  


# Définition des volumes
  volumes:
  - name: volume-web
    emptyDir: {}
```

**Action** – Convertit l'exemple précédent en format JSON.

---

> **NOTE**: L'indentation est obligatoire. Au moins un ' ' pour représenter les sous éléments d'un bloc. Il faut ABSOLUMENT utiliser la même indentation pour tous les éléments d'une liste.

```yaml
# Ceci est valide:
mammifères:
 - chat
 - chien
 - souris

# ceci est INVALIDE:
mammifères:
 - chat
- chien  # !! Indentation incorrecte 
 - souris

# ceci est AUSSI INVALIDE:
mammifères:
 - chat
  - chien  # !! Indentation incorrecte 
 - souris
```

**3.1b – JSON**

```json
{
  "mammifères": [
    "chat",
    "chien",
    "souris"
  ]
}

{
  "poissons": [
     "ange",
     "truite",
     "saumon"
  ]
}
```

---

### 3.1c – Exemple d'une structure imbriquée: {#section-3-1c}

```yaml
---
mammifères:
  - chat:
    - brun
    - noir
  - chien
  - souris
mammifères2:
  - chat
  - chien
  - souris
```

**JSON:**

```json
{
  "mammifères": [
    {
      "chat": [
        "brun",
        "noir"
      ]
    },
    "chien",
    "souris"
  ],
  "mammifères2": [
    "chat",
    "chien",
    "souris"
  ]
}
```

### 3.2 – Structures complexes – valeurs imbriquées {#section-3-2}

```yaml
# Un livre marquant
Origine-des-espèces: 
  auteur: Charles Darwin
  date: 1859-11-24
  page: 502
  genres: 
    - Traité
    - Publication scientifique
```

**3.2b – JSON**

```json
{
  "Origine-des-espèces": {
    "auteur": "Charles Darwin",
    "date": "1859-11-24T00:00:00.000Z",
    "page": 502,
    "genres": [
      "Traité",
      "Publication scientifique"
    ]
  }
}
```

---

## 4 – Les noeuds {#section-4}

### 4.1 – Réutilisation d'un noeud {#section-4-1}

```yaml
# Ancrage de nœuds - Réutilisation d'un nœud
auteur : &cDarwin
  prenom: Charles
  nom: Darwin
  naissance: 1809-02-12

Le-voyage-du-Beagle: 
  auteur: *cDarwin
  date: 1839-05-25
  page: 350
  réédition:
    - 1839
    - 1860
  genres: 
    - Biographie
    - Guide de voyage
    - Littérature de voyage
```

**4.1b – JSON**

```json
{
  "auteur": {
    "prenom": "Charles",
    "nom": "Darwin",
    "naissance": "1809-02-12T00:00:00.000Z"
  },
  "Le-voyage-du-Beagle": {
    "auteur": {
      "prenom": "Charles",
      "nom": "Darwin",
      "naissance": "1809-02-12T00:00:00.000Z"
    },
    "date": "1839-05-25T00:00:00.000Z",
    "page": 350,
    "réédition": [
      1839,
      1860
    ],
    "genres": [
      "Biographie",
      "Guide de voyage",
      "Littérature de voyage"
    ]
  }
}
```

**Autre exemple avec `<<:`**

```yaml
par_defaut: &defaut
  rôle: utilisateur
  actif: true

alice:
  <<: *defaut
  nom: Alice

bob:
  <<: *defaut
  nom: Bob
  actif: false
```

**JSON:**

```json
{
  "par_defaut": {
    "rôle": "utilisateur",
    "actif": true
  },
  "alice": {
    "rôle": "utilisateur",
    "actif": true,
    "nom": "Alice"
  },
  "bob": {
    "rôle": "utilisateur",
    "actif": false,
    "nom": "Bob"
  }
}
```

---

###### Document rédigé par Alain Boudreault (c) 2021-2025 – Révision 2026.11.07