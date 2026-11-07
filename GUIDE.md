# Guide d'entretien du site 420-4D4

Le site <https://ve2cuy.github.io/4204d4/> est construit par GitHub Pages (Jekyll) à chaque
poussée sur `main`. Il n'y a rien à installer : on modifie des fichiers Markdown, on pousse, et le
site se met à jour en une ou deux minutes.

**Tout le contenu de l'accueil est dans `index.md`, en Markdown ordinaire.** Le fichier se lit tel
quel sur github.com; sur le site, un petit script (`assets/js/accueil.js`) en fait la mise en page
(vignettes, cartes, encadrés) en suivant quelques règles simples, décrites plus bas.

## Où se trouve quoi

| Fichier ou dossier | Rôle |
|---|---|
| `index.md` | **L'accueil** : en-tête, présentation, enseignant, sections A à E et leurs documents |
| `Documentation/`, `Installation/` | Le contenu des documents, en Markdown |
| `dessins/*.svg` | Les dessins des cartes et des sections |
| `Documentation/images/` | Les images des documents et de l'accueil |
| `_layouts/`, `assets/` | Le thème, la mise en page de l'accueil et le tableau de bord (normalement, on n'y touche pas) |
| `assets/data/sessions.json` | Le calendrier de la session, pour le tableau de bord |
| `README.md` | La page du dépôt sur github.com; **elle n'apparaît pas sur le site** |
| `outils/` | L'aperçu local (`outils/apercu.sh`), non publié |

## Modifier le contenu d'un document

Ouvrir le fichier dans `Documentation/`, par exemple `Documentation/Docker/Docker-Hub.md`, le modifier en
Markdown, puis pousser. La page garde le thème toute seule.

Pour une image, la déposer dans `Documentation/images/` et y faire référence depuis le document :

```markdown
![Le montage du laboratoire](../images/mon-montage.jpg)
```

Le chemin se compte à partir du document : `../images/` pour un document de `Documentation/Docker/`.

### Exemples qui contiennent des `{{ }}` ou des `{% %}`

Jekyll prend les doubles accolades pour ses propres variables et les retire de la page publiée :
`docker ps --format '{{.Names}}'` deviendrait `docker ps --format ''`. C'est le cas des formats Go
de Docker et de Kubernetes, des gabarits Helm et des expressions des GitHub Actions
(`${{ secrets.… }}`). Entourer le bloc de code de `{% raw %}` et `{% endraw %}`, chacun sur sa
ligne et avec la même indentation que le bloc :

````markdown
{% raw %}
```bash
docker ps --format 'table {{.ID}}\t{{.Names}}'
```
{% endraw %}
````

Sur le site, ces deux marques disparaissent et le bloc s'affiche tel quel; sur github.com, elles
restent visibles. Pour une seule ligne hors d'un bloc (une ligne de tableau, par exemple), les
mettre au début et à la fin de la ligne. L'aperçu local (`outils/apercu.sh`) affiche un
« Liquid Warning » quand des accolades ne sont pas protégées, mais pas toujours : vérifier la page.

## L'accueil : `index.md`

### L'en-tête

Les quatre lignes du haut du fichier, entre les deux `---`, remplissent l'en-tête :

```yaml
---
layout: accueil
bandeau: "420-4D4-JR · techniques de l'informatique · cégep de saint-jérôme"
titre: "Serveurs Internet."
accroche: "Introduction à Docker et Kubernetes : conteneurs, images, Docker Compose…"
image: Documentation/images/serveurs-entete.png
---
```

`layout: accueil` doit rester tel quel. Les initiales des mots du titre (de quatre lettres et
plus) sont mises en couleur automatiquement. Le tableau de bord de la session s'ajoute à droite.

### Les règles de mise en page

| Ce qu'on écrit en Markdown | Ce que le site affiche |
|---|---|
| `## Titre` | Une section, séparée des autres par un trait |
| `## C) Titre` (une lettre majuscule et une parenthèse) | Une section lettrée, avec sa vignette dans la rangée du haut |
| Juste sous le titre : `![](dessins/nom.svg) *Description*` | Le dessin de la section, à côté du titre; la description sert à la vignette du haut |
| Une liste dont chaque élément commence par un dessin | Des cartes de documents, cinq par rangée |
| Une liste dont chaque élément commence par `**Libellé**` | Des encadrés « libellé / valeur » (programme, pondération, courriel…) |
| Un paragraphe qui ne contient qu'une photo | La photo ronde, avec le paragraphe suivant à côté |
| Un paragraphe qui ne contient que des liens, séparés par `·` | Des boutons |
| Tout le reste (paragraphes, listes ordinaires, **gras**, liens) | Du texte normal |

### Une carte de document

Une carte, c'est **une ligne de liste** :

```markdown
- ![](dessins/cle.svg) 26 · [Kubernetes – Config Map et Secrets](Documentation/Kubernetes/Kubernetes-Config-map-et-secret.md) · 👍
```

| Partie | Effet |
|---|---|
| `![](dessins/cle.svg)` | Le dessin (obligatoire, en premier); liste des dessins plus bas |
| `26` | Le numéro (1 à 4 lettres ou chiffres : `21`, `08b`, `F1`), suivi de ` · `; `+` pour un document d'appoint sans numéro |
| `[Titre](lien)` | Le titre et le lien : un document `Documentation/…/Nom.md`, un PDF, un dossier ou une adresse `https://…` |
| ` · 👍` | Facultatif : une petite étiquette (`👍`, `🧠`, `désuet`, `30 %`…) |

Sans lien (seulement du texte à la place de `[Titre](lien)`), la carte est grisée avec la mention
« sans page ». Une **sous-liste** (deux espaces puis `-`) ajoute une ligne de détails en petit :

```markdown
- ![](dessins/compose.svg) 13a · [Docker-Compose – Partie 1](Documentation/Docker/Docker-compose-p1.md)
  - Services, réseaux et volumes d'une application
```

Les couleurs des dessins alternent d'elles-mêmes d'une carte à l'autre. Une liste dont toutes les
cartes sont numérotées par une seule lettre (`A`, `B`) s'affiche en grandes cartes; pour les garder
de la taille des autres, ajouter `grandes_cartes: false` dans l'en-tête d'`index.md`.

### Autres possibilités

| Ce qu'on écrit | Effet |
|---|---|
| `- ![Description](images/photo.jpg) - · [Titre](lien)` | Une carte avec une **photo** au lieu d'un dessin (toute image qui n'est pas dans `dessins/`) |
| `… · [Titre](lien) · étiquette · [Dépôt GitHub](https://github.com/…)` | Des **liens de plus** sur la carte, en boutons; le titre reste le lien principal |
| `-` à la place du numéro | Aucun numéro affiché sur le dessin |
| `420-1C4` comme numéro | Un code de cours sert aussi de numéro |
| `image_ronde: true` dans l'en-tête d'`index.md` | L'image de l'en-tête s'affiche en rond (pour une photo) |
| Un titre de plus de 30 caractères | Il s'affiche un peu plus petit, pour rester moins haut que le tableau de bord |

Le menu du haut se règle dans `_config.yml` (sinon : ve2cuy.github.io, Documents, Enseignant) :

```yaml
navigation:
  - titre: "Cours"
    lien: "/#section-a"
  - titre: "Blogue"
    lien: "https://ve2cuy.github.io/blog/"
```

## Exemples

### Ajouter un document

1. Créer la page, par exemple `Documentation/Kubernetes/Kubernetes-Namespaces.md`, qui commence par son titre :

   ```markdown
   # Kubernetes – Espaces de nom

   Le texte du document…
   ```

2. Dans `index.md`, ajouter sa ligne dans la liste de sa section, **à l'endroit où la carte doit
   paraître** :

   ```markdown
   - ![](dessins/espaces.svg) 35 · [Espaces de nom (namespaces)](Documentation/Kubernetes/Kubernetes-Namespaces.md) · 🧠
   ```

3. Pousser.

### Autres cas

Un document d'appoint sans numéro :

```markdown
- ![](dessins/livres.svg) + · [Docker – Référence rapide](Documentation/Docker/Docker-Reference-rapide.md) · 👍
```

Un document prévu, sans page pour l'instant :

```markdown
- ![](dessins/badge.svg) 36 · ServiceAccount · 🧠
```

Un lien vers une page extérieure :

```markdown
- ![](dessins/cluster.svg) + · [Documentation officielle de Kubernetes](https://kubernetes.io/fr/docs/home/) · lien externe
```

### Modifier, déplacer ou retirer une carte

- **Changer un titre, un numéro ou une étiquette :** modifier la ligne.
- **Changer l'ordre ou la section :** couper la ligne et la coller à sa nouvelle place.
- **Retirer une carte :** supprimer la ligne. La page `Documentation/…md` reste en ligne tant que le
  fichier existe; la supprimer aussi si elle ne doit plus être accessible.

### Ajouter une section (par exemple F)

À la fin d'`index.md` :

```markdown
## F) Formatifs

![](dessins/fiole.svg) *Ateliers de renforcement*

- ![](dessins/chat.svg) F1 · [Dockerfile – SuperMinou](Documentation/Docker/Dockerfile-atelier-de-renforcement.md)
```

La vignette F apparaît dans la rangée du haut, avec sa couleur et sa description.

### Modifier la présentation ou l'enseignant

Ce sont des paragraphes et des listes ordinaires sous leur titre `##` : les modifier comme du
texte. Les encadrés sont des lignes `- **Libellé** : valeur`; les boutons, une ligne de liens
séparés par ` · `.

## Les dessins

Dessins disponibles (`dessins/`) :

`accolades`, `autoscale`, `badge`, `balance`, `bande-del`, `bits`, `bouton`, `capteur-sans-fil`, `carte-arduino`, `chat`, `cle`, `cle-a-molette`, `cluster`, `compose`, `conteneur`, `conteneur-vm`, `copier-coller`, `couches`, `coupe`, `crayon`, `disque`, `document`, `dossier-lien`, `drapeau`, `eeprom`, `engrenage`, `enseignant`, `espaces`, `etiquette`, `feuilles`, `fiche-info`, `fiole`, `horloge`, `infrarouge`, `jauge`, `lcd`, `liste`, `livres`, `microcontroleur`, `minuterie`, `mouvement`, `multi-services`, `nuage`, `oeil`, `porte-documents`, `potentiometre`, `puce-del`, `registre`, `reseau`, `resistance-del`, `rfid`, `roue`, `serveur`, `solutions`, `structure`, `tableau-de-bord`, `telechargement`, `terminal`, `thermometre`, `uart`, `wifi`, `yaml`.

Sur github.com, ils s'affichent en bleu; sur le site, ils prennent les couleurs du thème clair ou
sombre.

### Ajouter un dessin

Copier un fichier de `dessins/` sous un nouveau nom, par exemple `dessins/ingress.svg`, et
remplacer les formes. Le dessin occupe une surface de 200 × 100, en traits sans remplissage :

```html
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 100" width="200" height="100" fill="none"
     stroke="#4a8fd0" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <rect x="70" y="26" width="60" height="48" rx="6"/><path d="M80 26v-9M120 26v-9"/>
</svg>
```

Puis l'utiliser avec `![](dessins/ingress.svg)`. Les formes simples (`rect`, `circle`, `path`)
rendent le mieux; s'inspirer des dessins existants.

## Le tableau de bord de la session

Il lit `assets/data/sessions.json` (jours de classe et numéros de semaine de chaque session). À
chaque nouvelle session, refaire ce fichier avec l'outil du site ve2cuy.com
(`ve2cuy-site/tools/calendrier.py`, voir son README) à partir du PDF du calendrier du Cégep, puis
copier le même `sessions.json` ici.

Pour vérifier une date précise : <https://ve2cuy.github.io/4204d4/?date=2027-03-31>.

## Aperçu local (valider avant de publier)

Le script `outils/apercu.sh` construit et sert le site sur le Mac avec la **même version de
Jekyll que GitHub Pages**, pour voir le résultat avant de pousser.

### Une seule fois

Installer Ruby par Homebrew (le Ruby fourni avec macOS est trop ancien) :

```bash
brew install ruby
```

Au premier lancement, le script installe lui-même les gemmes de GitHub Pages dans
`~/.gem/pages` (quelques minutes; rien n'est installé dans le système).

### À chaque séance

Depuis le dossier du dépôt :

```bash
outils/apercu.sh
```

puis ouvrir <http://127.0.0.1:4000/4204d4/>. Le `/4204d4/` est nécessaire, comme sur GitHub
Pages. À chaque fichier enregistré (un document, `index.md`, un dessin…), le site se
reconstruit en moins d'une seconde et la page ouverte se recharge seule. **Ctrl+C** arrête
l'aperçu.

Autres usages :

| Commande | Effet |
|---|---|
| `outils/apercu.sh 4001` | Aperçu sur un autre port (si 4000 est déjà pris) |
| `outils/apercu.sh --build` | Construit seulement le site dans `_site/` et s'arrête : pratique pour vérifier qu'il n'y a pas d'erreur avant de pousser |

Le tableau de bord se teste aussi en local : <http://127.0.0.1:4000/4204d4/?date=2027-03-31>.

### Le contenu d'`outils/`

| Fichier | Rôle |
|---|---|
| `apercu.sh` | Le script : prépare Ruby, installe les gemmes au besoin, construit et sert le site |
| `Gemfile` | Les gemmes : `github-pages` (la même version de Jekyll que GitHub) et quelques bibliothèques retirées du Ruby récent |
| `apercu.yml` | Les extensions que GitHub Pages active d'office (pages Markdown sans en-tête, liens `.md` convertis en `.html`, titres tirés du premier titre) |
| `ruby4-compat.rb` | Comble l'écart entre ce Jekyll et le Ruby récent (méthodes `tainted?` et `untaint` retirées) |

### Ce qu'il faut savoir

- `_site/` (le site construit) et `.jekyll-cache/` ne vont pas dans Git (`.gitignore`).
- Une erreur dans un fichier s'affiche dans le terminal, avec son nom : la corriger,
  enregistrer, et l'aperçu repart.
- Le dossier `outils/` (le script, sa configuration et son `Gemfile`) n'est pas publié sur le site.
- Ce Jekyll est plus ancien que le Ruby de Homebrew : `outils/ruby4-compat.rb` et les gemmes
  supplémentaires du `Gemfile` comblent l'écart, pour l'aperçu seulement. GitHub, lui, construit
  le site dans son propre environnement.
- Dans de rares cas, une différence peut apparaître entre l'aperçu et le site publié : vérifier le
  site en ligne après chaque publication importante.

## Publier

```bash
git add -A
git commit -m "Ajout du document 35 : espaces de nom"
git push
```

Le site se met à jour en une ou deux minutes (onglet **Actions** du dépôt pour suivre). Faire
Cmd+Maj+R dans le fureteur pour voir la nouvelle version.

Si GitHub envoie un courriel « deploy failed » alors que l'étape **build** a réussi, c'est
presque toujours un délai dépassé de son côté : dans **Actions**, ouvrir l'exécution et cliquer
**Re-run failed jobs**, ou simplement pousser le commit suivant.

Si l'étape **build** échoue, c'est en général une erreur dans l'en-tête d'`index.md` (entre les
`---`, un guillemet oublié) : le message de l'onglet **Actions** donne le fichier et la ligne.

Si une carte ne s'affiche pas comme prévu, vérifier sa ligne : le dessin doit venir en premier,
suivi du numéro et de ` · `.
