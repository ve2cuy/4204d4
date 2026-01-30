# YAML – Référence

*Date: 2 Décembre 2025*

---

# 🇾🇦 YAML — Références et exemples

**Référence**: [YAML](https://yaml.org/spec/1.2/spec.html)

**Validateur YAML en ligne**: [yamllint](http://www.yamllint.com)

**Convertisseur YAML → JSON**: [onlineyamltools](https://onlineyamltools.com/convert-yaml-to-json)

---

## 1. Qu'est-ce que YAML ?

YAML signifie **"YAML Ain't Markup Language"**.  

C'est un format de fichier **lisible par l'humain**, utilisé pour représenter des données structurées (configuration, échanges entre services, automatisation, etc.).

### Pourquoi YAML ?

* Très lisible
* Simplicité de la structure
* Supporte les types usuels (texte, nombres, listes, objets…)
* Fréquent dans DevOps, Kubernetes, Ansible, CI/CD, etc.

---

## 2. Règles fondamentales

### 2.1 Indentation

L'indentation définit la structure.  
⚠️ **Toujours utiliser des espaces, jamais des tabulations**.

Exemple :

```yaml
personne:
  nom: Dupont
  age: 30
```

### 2.2 Paires clé-valeur

```yaml
clé: valeur
```

Exemples :

```yaml
nom: Alice
age: 27
langue: français
```

### 2.3 Commentaires

On utilise `#` :

```yaml
version: 1.2  # numéro de version
```

---

## 3. Types de données

### 3.1 Chaînes de caractères

```yaml
message: "Bonjour"
autre: Bonjour
ligne_multiple: |
  Ceci est une chaîne
  sur plusieurs lignes.
```

#### Chaînes littérales vs chaînes pliées

```yaml
texte_litteral: |
  Première ligne
  Deuxième ligne

texte_plie: >
  Ceci est un texte
  qui sera mis sur une seule ligne.
```

---

### 3.2 Nombres

```yaml
entier: 42
flottant: 3.14
scientifique: 1e6
```

---

### 3.3 Booléens

```yaml
actif: true
connecté: false
```

---

### 3.4 Valeur nulle

```yaml
champ_vide: null
champ2: ~
```

---

## 4. Collections

### 4.1 Listes

#### Liste simple

```yaml
fruits:
  - pomme
  - banane
  - kiwi
```

#### Liste sur une seule ligne

```yaml
couleurs: [rouge, vert, bleu]
```

### 4.2 Dictionnaires (objets / maps)

```yaml
utilisateur:
  nom: Martin
  ville: Québec
  actif: true
```

### 4.3 Combiner listes et dictionnaires

#### Liste de dictionnaires :

```yaml
employes:
  - nom: Alice
    poste: développeuse
  - nom: Bob
    poste: designer
```

#### Dictionnaire contenant des listes

```yaml
produit:
  nom: Ordinateur
  options:
    - SSD
    - 32GB RAM
```

---

## 5. Références et ancres

Permettent d'éviter la répétition de blocs.

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

---

## 6. Séparateurs de documents

Permet d'avoir plusieurs documents YAML dans un seul fichier :

```yaml
---
nom: Alice
age: 31
---
nom: Bob
age: 28
```

---

## 7. Bonnes pratiques

✔️ Utiliser 2 espaces pour l'indentation  
✔️ Bien structurer les données selon leur sens  
✔️ Préférer le style multi-ligne (`|`) pour garder la mise en forme  
✔️ Utiliser des ancres pour éviter les répétitions  
✔️ Valider votre fichier avec un linter YAML

---

## 8. Exemples complets

### 8.1 Fichier de configuration d'application

```yaml
application:
  nom: MonApp
  version: 1.0

serveur:
  port: 8080
  mode: production

base_de_données:
  hôte: localhost
  port: 5432
  utilisateur: admin
  mot_de_passe: secret
```

---

### 8.2 Exemple type Kubernetes (simplifié)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mon-pod
spec:
  containers:
    - name: app
      image: monapp:latest
      ports:
        - containerPort: 3000
```

---

### 8.3 Exemple Ansible

```yaml
- name: Installer nginx
  hosts: web
  become: true
  tasks:
    - name: Installer paquet nginx
      apt:
        name: nginx
        state: present
```

---

## 9. Pièges courants

❌ **Tabulations interdites**  
❌ Ne pas mélanger indentation de 2 et 4 espaces  
❌ Les caractères spéciaux doivent être entre guillemets :

```yaml
mot_de_passe: "!#%secret"
```

---

## 10. Outils utiles

* **YamlLint** (validation)
* **VSCode + extension YAML**
* **PyYAML** (Python)
* **js-yaml** (JavaScript)

---

## Crédits

*Contenu par ve2cuy*