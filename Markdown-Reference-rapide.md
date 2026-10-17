# 🚀 GitHub Markdown (GFM) - Référence rapide

## 1\. Titres et Texte de Base

| Élément | Syntaxe Markdown | Rendu (Exemple) |
| :--- | :--- | :--- |
| **Titre 1** | `# Titre 1` | \# Titre 1 |
| **Titre 2** | `## Titre 2` | \#\# Titre 2 |
| **Titre 3** | `### Titre 3` | \#\#\# Titre 3 |
| **Gras (Bold)** | `**texte en gras**` ou `__texte en gras__` | **texte en gras** |
| **Italique** | `*texte en italique*` ou `_texte en italique_` | *texte en italique* |
| **Barré** | `~~texte barré~~` | \~\~texte barré\~\~ |
| **Citation (Blockquote)** | `> Ceci est une citation.` | \> Ceci est une citation. |
| **Nouvelle Ligne** | ` Fin de ligne suivie de deux espaces.   ` | (Ajouter deux espaces à la fin de la ligne) |
| **Règle Horizontale** | `---` ou `***` | --- |

-----

## 2\. Listes

### Listes Non Ordonnées

```markdown
* Élément 1
* Élément 2
  * Sous-élément
```

  * Élément 1
  * Élément 2
      * Sous-élément

### Listes Ordonnées

```markdown
1. Premier élément
2. Deuxième élément
3. Troisième élément
```

1.  Premier élément
2.  Deuxième élément
3.  Troisième élément

### Listes de Tâches (GFM Spécifique)

```markdown
- [x] Tâche terminée
- [ ] Tâche à faire
- [ ] Tâche prioritaire
```

  - [x] Tâche terminée
  - [ ] Tâche à faire
  - [ ] Tâche prioritaire

-----

## 3\. Code et Mise en Évidence

| Élément | Syntaxe Markdown | Rendu (Exemple) |
| :--- | :--- | :--- |
| **Code en Ligne** | ` Utiliser la commande  ` `kubectl get pods` `.` | Utiliser la commande `kubectl get pods`. |
| **Bloc de Code** | `     `bash\\necho "Hello"\\n`     ` | (Voir l'exemple ci-dessous) |

### Bloc de Code avec Coloration Syntaxique (Fenced Code Block)

Entourez votre code de trois apostrophes inversées (backticks) et spécifiez le langage :

\<pre\>

```javascript
const message = &quot;Salut Monde&quot;;
console.log(message);
```

\</pre\>

Rendu :

```javascript
const message = "Salut Monde";
console.log(message);
```

-----

## 4\. Liens et Images

| Élément | Syntaxe Markdown | Rendu (Exemple) |
| :--- | :--- | :--- |
| **Lien** | `[Texte du lien](https://www.github.com)` | [Texte du lien](https://www.github.com) |
| **Lien URL** | `<https://www.github.com>` | [https://www.github.com](https://www.github.com) |
| **Image** | `![Texte alternatif](URL de l'image)` | `![Logo GitHub](https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png)` |

-----

## 5\. Tableaux

Pour créer un tableau, utilisez des **barres verticales (`\|`)** pour séparer les colonnes et des **tirets (`-`)** pour séparer l'en-tête du corps.

```markdown
| En-tête 1 | En-tête 2 | En-tête 3 |
| :--- | :---: | ---: |
| Align. Gauche | Align. Centre | Align. Droite |
| Donnée 1 | Donnée 2 | Donnée 3 |
```

| En-tête 1 | En-tête 2 | En-tête 3 |
| :--- | :---: | ---: |
| Align. Gauche | Align. Centre | Align. Droite |
| Donnée 1 | Donnée 2 | Donnée 3 |

-----

## 6\. Fonctionnalités GFM Spécifiques

Ces fonctionnalités sont essentielles pour l'environnement GitHub (issues, pull requests, commentaires).

| Élément | Syntaxe GFM | Description |
| :--- | :--- | :--- |
| **Mention Utilisateur** | `Salut @ve2cuy !` | Notifie un utilisateur GitHub (lien cliquable). |
| **Référence** | `Fixe #42` | Crée un lien vers l'Issue ou la Pull Request n°42. |
| **Émoji** | `:smile:` ou `:tada:` | Convertit le shortcode en émoji (utiliser le clavier pour des émojis natifs est aussi possible). |
| **Début/Fin de Bloc** | `[comment]: # (Ce texte sera masqué)` | Permet d'ajouter des commentaires masqués dans le Markdown. |
| **Auto-lien SHA** | `Le commit est 16f2127.` | Le SHA complet ou partiel d'un commit dans le même dépôt est automatiquement lié. |