# 9 - Convention de nommage des labels

*Révision du 2026.11.07*

## Objectif de la lecture

À la fin de cette lecture, nous devrions être capable d'**ajouter des métadonnées** (labels) à nos images Docker en respectant les **conventions** reconnues par les outils (Docker Hub, GitHub, scanners de sécurité, etc.), de les **consulter** et de les **filtrer**, et de les **produire automatiquement** lors de la construction d'une image.

*A.B. aka ve2cuy*

---

## Contenu

- [**1 – Qu'est-ce qu'un label ?**](#section-1)
- [**2 – Règles de nommage des clés**](#section-2)
- [**3 – L'ancienne convention : org.label-schema**](#section-3)
  - [3.1 – Labels principaux](#section-3-1)
  - [3.2 – Exemple pratique dans un Dockerfile](#section-3-2)
- [**4 – La convention actuelle : OCI**](#section-4)
  - [4.1 – Les clés org.opencontainers.image.*](#section-4-1)
  - [4.2 – Correspondance label-schema → OCI](#section-4-2)
  - [4.3 – Exemple moderne (OCI)](#section-4-3)
- [**5 – Automatisation avec des variables**](#section-5)
  - [5.1 – Avec ARG](#section-5-1)
  - [5.2 – Avec l'option --label](#section-5-2)
- [**6 – Consulter et filtrer les labels**](#section-6)
- [**7 – Labels et Docker Compose**](#section-7)
- [**8 – Héritage des labels**](#section-8)
- [**9 – Labels ou annotations ?**](#section-9)
- [**10 – Dans GitHub Actions**](#section-10)
- [**11 – Cas d'usage**](#section-11)
- [**12 – Laboratoires**](#section-12)
  - [12.1 – Laboratoire (durée 20 minutes)](#section-12-1)
  - [12.2 – Laboratoire (durée 30 minutes)](#section-12-2)
  - [12.3 – Laboratoire (durée 30 minutes)](#section-12-3)

---

## 1 – Qu'est-ce qu'un label ? {#section-1}

Un **label** est une paire **clé=valeur** qui accompagne un objet Docker : une image, un conteneur, un volume ou un réseau. Il ne change rien au fonctionnement de l'objet : il le **décrit**.

Dans un Dockerfile, la directive `LABEL` ajoute des labels à l'image :

```dockerfile
FROM alpine
LABEL org.opencontainers.image.title="Bonjour 420-4D4" \
      org.opencontainers.image.version="1.0"
```

Les labels sont enregistrés dans la configuration de l'image (`Config.Labels`). Ils voyagent avec elle sur Docker Hub et sont copiés dans chaque conteneur créé à partir de cette image.

> 💡Les clés et les valeurs sont toujours des **chaînes de caractères**. Une valeur peut contenir du JSON, du YAML, etc., mais Docker ne l'interprète pas.

---

## 2 – Règles de nommage des clés {#section-2}

Pour éviter que deux outils utilisent la même clé avec des sens différents, Docker recommande :

* **Notation DNS inversée** : préfixer la clé par un domaine que l'on possède, à l'envers. Par exemple, pour le domaine `cstj.qc.ca` : `ca.qc.cstj.cours`.
* **Minuscules** : une clé commence et se termine par une lettre minuscule; elle ne contient que des lettres minuscules, des chiffres, des points (`.`) et des tirets (`-`).
* Pas de **points ou de tirets consécutifs** (`..`, `--`).
* Le **point** sépare les « champs » de l'espace de noms.
* Préfixes **réservés** : `com.docker.*`, `io.docker.*` et `org.dockerproject.*` (Docker), `org.opencontainers.*` (spécifications OCI).
* Les clés **sans espace de noms** (`version`, `auteur`) sont réservées à l'usage interactif en ligne de commande.

| Clé | Correcte ? | Pourquoi |
|-----|------------|----------|
| `ca.qc.cstj.cours` | ✅ | DNS inversé, minuscules |
| `org.opencontainers.image.version` | ✅ | Clé définie par la spécification OCI |
| `Auteur` | ❌ | Majuscule, pas d'espace de noms |
| `com.docker.mon-label` | ❌ | Préfixe réservé à Docker |
| `ca.qc.cstj..cours` | ❌ | Points consécutifs |

*Tableau 01*

> Note: Ces règles ne sont pas imposées par Docker : une clé incorrecte est acceptée. Mais les outils qui lisent les labels s'attendent à ces conventions.

---

## 3 – L'ancienne convention : `org.label-schema` {#section-3}

`org.label-schema` est une **convention de nommage standardisée** pour les labels des images Docker, proposée vers 2016. Son objectif : permettre à tous les créateurs d'images d'utiliser les **mêmes clés de métadonnées** pour décrire leurs images, facilitant ainsi :

- L'automatisation
- La découverte d'informations
- La gestion des images
- L'audit et la conformité

**⚠️ Note importante** : `org.label-schema` est maintenant **remplacée** par la convention **OCI** (section 4). On la rencontre encore dans de nombreuses images existantes : il faut savoir la lire, mais utiliser OCI pour les nouvelles images.

### 3.1 – Labels principaux {#section-3-1}

| Label | Description | Exemple |
|-------|-------------|---------|
| `org.label-schema.schema-version` | Version du schéma | `1.0` |
| `org.label-schema.name` | Nom de l'image | `Mon Application` |
| `org.label-schema.description` | Description | `API REST en Python` |
| `org.label-schema.version` | Version de l'application | `2.1.5` |
| `org.label-schema.build-date` | Date de construction | `2024-03-15T10:30:00Z` |
| `org.label-schema.vcs-url` | URL du dépôt Git | `https://github.com/user/repo` |
| `org.label-schema.vcs-ref` | Commit Git | `abc123def` |
| `org.label-schema.vendor` | Créateur/Organisation | `Ma Compagnie Inc.` |
| `org.label-schema.url` | Site web du projet | `https://monapp.com` |
| `org.label-schema.docker.cmd` | Commande d'exécution | `docker run -p 8080:8080 monapp` |

*Tableau 02*

### 3.2 – Exemple pratique dans un Dockerfile {#section-3-2}

```dockerfile
FROM node:18-alpine

# Métadonnées selon org.label-schema
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="Mon API REST" \
      org.label-schema.description="API REST pour la gestion des utilisateurs" \
      org.label-schema.version="2.1.5" \
      org.label-schema.build-date="2024-12-22T14:30:00Z" \
      org.label-schema.vcs-url="https://github.com/monentreprise/api-users" \
      org.label-schema.vcs-ref="a3f7b2c" \
      org.label-schema.vendor="Mon Entreprise Inc." \
      org.label-schema.url="https://api.monentreprise.com" \
      org.label-schema.docker.cmd="docker run -p 3000:3000 monapi"

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

EXPOSE 3000
CMD ["npm", "start"]
```

> 💡Une seule directive `LABEL` avec des `\` en fin de ligne plutôt qu'une directive par label : le Dockerfile est plus lisible.

---

## 4 – La convention actuelle : OCI {#section-4}

L'**OCI** (*Open Container Initiative*) est l'organisme qui normalise le format des images et des conteneurs, utilisé par Docker, Podman, Kubernetes, etc. Sa spécification d'image définit des **annotations** prédéfinies, avec le préfixe `org.opencontainers.image`. Dans un Dockerfile, on les utilise comme labels.

### 4.1 – Les clés `org.opencontainers.image.*` {#section-4-1}

| Clé (`org.opencontainers.image.…`) | Contenu | Exemple |
|-----------------------------------|---------|---------|
| `created` | Date et heure de la construction, format RFC 3339 | `2026-11-07T14:30:00Z` |
| `authors` | Personnes ou organisation responsables (texte libre) | `Alain Boudreault <aboudrea@cstj.qc.ca>` |
| `url` | Page d'information sur l'image | `https://hub.docker.com/r/alainboudreault/superminou` |
| `documentation` | Page de documentation | `https://ve2cuy.github.io/4204d4/` |
| `source` | Code source qui a servi à construire l'image | `https://github.com/ve2cuy/superminou-depart` |
| `version` | Version du logiciel (souvent une version sémantique ou l'étiquette Git) | `2.1.5` |
| `revision` | Identifiant de révision du code source (commit) | `a3f7b2c` |
| `vendor` | Organisation ou personne qui distribue l'image | `Cégep de Saint-Jérôme` |
| `licenses` | Licence(s), en expression **SPDX** | `MIT`, `Apache-2.0`, `MIT OR Apache-2.0` |
| `title` | Titre lisible de l'image | `SuperMinou` |
| `description` | Description du logiciel contenu dans l'image | `Site web de démonstration` |
| `base.name` | Image de base (`FROM`), nom complet avec le registre | `docker.io/library/nginx:1.27-alpine` |
| `base.digest` | Empreinte (*digest*) de l'image de base | `sha256:4ff1…` |
| `ref.name` | Nom de référence dans une disposition d'image OCI (rarement utilisé à la main) | `1.0` |

*Tableau 03*

### 4.2 – Correspondance label-schema → OCI {#section-4-2}

Selon la spécification OCI :

| `org.label-schema.…` | `org.opencontainers.image.…` | Remarque |
|----------------------|------------------------------|----------|
| `build-date` | `created` | Compatible |
| `url` | `url` | Compatible |
| `vcs-url` | `source` | Compatible |
| `version` | `version` | Compatible |
| `vcs-ref` | `revision` | Compatible |
| `vendor` | `vendor` | Compatible |
| `name` | `title` | Compatible |
| `description` | `description` | Compatible |
| `usage` | `documentation` | Si la documentation est une URL |
| — | `authors` | Pas d'équivalent dans label-schema |
| — | `licenses` | Pas d'équivalent dans label-schema |
| `schema-version` | — | Pas d'équivalent dans OCI |
| `docker.*` (ex. `docker.cmd`) | — | Pas d'équivalent dans OCI |

*Tableau 04*

### 4.3 – Exemple moderne (OCI) {#section-4-3}

```dockerfile
FROM node:18-alpine

LABEL org.opencontainers.image.created="2026-11-07T14:30:00Z" \
      org.opencontainers.image.authors="dev@monentreprise.com" \
      org.opencontainers.image.url="https://monapp.com" \
      org.opencontainers.image.documentation="https://docs.monapp.com" \
      org.opencontainers.image.source="https://github.com/user/repo" \
      org.opencontainers.image.version="2.1.5" \
      org.opencontainers.image.revision="a3f7b2c" \
      org.opencontainers.image.vendor="Mon Entreprise Inc." \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="Mon API REST" \
      org.opencontainers.image.description="API pour la gestion des utilisateurs" \
      org.opencontainers.image.base.name="docker.io/library/node:18-alpine"

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

> 💡Sur le registre de GitHub (`ghcr.io`), le label `org.opencontainers.image.source` relie automatiquement l'image à son dépôt GitHub, et `org.opencontainers.image.description` s'affiche sur la page du paquet.

---

## 5 – Automatisation avec des variables {#section-5}

Une date ou un numéro de commit écrits à la main sont vite faux. Il vaut mieux les fournir au moment de la construction.

### 5.1 – Avec `ARG` {#section-5-1}

```dockerfile
FROM alpine:3.20

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=dev

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.title="Mon outil"

CMD ["echo", "Bonjour 420-4D4"]
```

**Build avec variables** (Linux, macOS ou Git Bash) :

```bash
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  --build-arg VERSION=2.1.5 \
  -t monoutil:2.1.5 .
```

**Sous PowerShell** :

```powershell
docker build `
  --build-arg BUILD_DATE=$((Get-Date).ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss'Z'")) `
  --build-arg VCS_REF=$(git rev-parse --short HEAD) `
  --build-arg VERSION=2.1.5 `
  -t monoutil:2.1.5 .
```

> Note: `ARG VERSION=dev` donne une valeur par défaut : sans `--build-arg VERSION=…`, le label vaut `dev`. Un `ARG` **sans** valeur par défaut et non fourni donne un label **vide** (`""`).

### 5.2 – Avec l'option `--label` {#section-5-2}

L'option `--label` de `docker build` ajoute (ou remplace) un label **sans modifier le Dockerfile** :

```bash
docker build \
  --label org.opencontainers.image.version=2.1.6 \
  --label org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  -t monoutil:2.1.6 .
```

> 💡Un label passé avec `--label` a priorité sur la même clé définie par `LABEL` dans le Dockerfile.

---

## 6 – Consulter et filtrer les labels {#section-6}

{% raw %}
```bash
# Tous les labels d'une image, en JSON lisible (avec jq)
docker image inspect monoutil:2.1.5 | jq '.[0].Config.Labels'

# Tous les labels, sans jq
docker image inspect --format '{{json .Config.Labels}}' monoutil:2.1.5

# Un label précis : la fonction « index » (la clé contient des points)
docker image inspect --format '{{ index .Config.Labels "org.opencontainers.image.version" }}' monoutil:2.1.5

# Les images qui ont un label (peu importe sa valeur)
docker images --filter "label=org.opencontainers.image.version"

# Les images dont le label a une valeur précise
docker images --filter "label=org.opencontainers.image.version=2.1.5"

# Les conteneurs dont l'image porte un label (les labels de l'image sont copiés dans le conteneur)
docker ps -a --filter "label=org.opencontainers.image.title=Mon outil"
```
{% endraw %}

> Note: {% raw %}`{{.Config.Labels.org.opencontainers.image.version}}`{% endraw %} ne fonctionne **pas** (`<no value>`) : les points de la clé sont pris pour des champs. D'où la fonction `index`.

---

## 7 – Labels et Docker Compose {#section-7}

**Attention à l'emplacement** : dans un fichier `docker-compose.yml`, `labels:` n'a pas le même effet selon l'endroit où on l'écrit.

```yaml
services:
  app:
    build:
      context: .
      labels:                       # Labels de l'IMAGE construite
        org.opencontainers.image.title: "Mon API"
        org.opencontainers.image.version: "2.1.5"
        org.opencontainers.image.vendor: "Mon Entreprise"
    image: monapi:2.1.5
    labels:                         # Labels du CONTENEUR seulement
      ca.qc.cstj.environnement: "production"
    ports:
      - "3000:3000"
```

* `build.labels` : ajoutés à **l'image**, comme `--label` au `docker build`. Les conteneurs les reçoivent aussi.
* `labels` du service : ajoutés au **conteneur** créé par Compose seulement. L'image n'en sait rien.

{% raw %}
```bash
docker compose build
docker image inspect --format '{{json .Config.Labels}}' monapi:2.1.5      # labels de l'image
docker compose up -d
docker inspect --format '{{json .Config.Labels}}' $(docker compose ps -q app)   # labels du conteneur
```
{% endraw %}

> Note: La ligne `version: '3.8'` en tête des fichiers Compose est **désuète** : Docker Compose l'ignore avec un avertissement (« the attribute `version` is obsolete »). Il n'est plus nécessaire de l'écrire.

---

## 8 – Héritage des labels {#section-8}

Une image **hérite des labels** de son image de base (`FROM`). Par exemple, l'image officielle `nginx` porte le label `maintainer`; une image construite à partir de `nginx` l'aura aussi.

```dockerfile
FROM nginx:1.27-alpine
# Remplace la valeur héritée de l'image nginx
LABEL maintainer="Alain Boudreault <aboudrea@cstj.qc.ca>"
```

{% raw %}
```bash
docker build -t monnginx .
docker image inspect --format '{{json .Config.Labels}}' nginx:1.27-alpine
# {"maintainer":"NGINX Docker Maintainers <docker-maint@nginx.com>"}
docker image inspect --format '{{json .Config.Labels}}' monnginx
# {"maintainer":"Alain Boudreault <aboudrea@cstj.qc.ca>"}
```
{% endraw %}

> 💡Une image construite à partir d'une image qui utilise déjà les labels OCI hérite de **son** titre, de **sa** version, de **sa** description… Il faut donc **redéfinir** ces labels dans son propre Dockerfile, sinon l'image décrit celle d'un autre !

---

## 9 – Labels ou annotations ? {#section-9}

La spécification OCI parle d'**annotations**; Docker parle de **labels**. Les clés sont les mêmes, mais l'endroit où elles sont enregistrées diffère :

| | Labels | Annotations |
|-|--------|-------------|
| Définis par | `LABEL` dans le Dockerfile, `--label` | `docker buildx build --annotation` |
| Enregistrés dans | La configuration de l'image (`Config.Labels`) | Le manifeste ou l'index de l'image, dans le registre |
| Copiés dans les conteneurs | Oui | Non |
| Lecture | `docker image inspect` | `docker buildx imagetools inspect --raw` |

*Tableau 05*

```bash
# Annotation sur le manifeste; il faut publier directement dans un registre (--push)
docker buildx build --push \
  --annotation "org.opencontainers.image.description=Mon API REST" \
  -t votrecompte/monapi:2.1.5 .

docker buildx imagetools inspect votrecompte/monapi:2.1.5 --raw
```

> Note: Le magasin d'images de Docker Engine ne conserve pas les annotations : une image construite avec `--annotation` doit être poussée vers un registre (`--push`).

**En pratique, dans ce cours** : les **labels** suffisent; les annotations servent surtout aux images multi-plateformes publiées par un pipeline CI/CD.

---

## 10 – Dans GitHub Actions {#section-10}

L'action officielle `docker/metadata-action` produit automatiquement les étiquettes (tags) **et les labels OCI** à partir du dépôt : `title`, `description`, `url`, `source`, `version`, `created`, `revision` et `licenses`.

{% raw %}
```yaml
      - name: Métadonnées de l'image (tags et labels OCI)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: votrecompte/monapi

      - name: Construire et publier
        uses: docker/build-push-action@v6
        with:
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```
{% endraw %}

Voir les documents [GitHub Actions](../Automatisation/github-action.md) et [GitHub Actions, version 2](../Automatisation/github-action-v2.md).

---

## 11 – Cas d'usage {#section-11}

1. **CI/CD** : tracer quelle version du code (`revision`) a généré une image.
2. **Audit** : savoir qui a créé l'image (`authors`, `vendor`) et quand (`created`).
3. **Documentation** : fournir des informations sans ouvrir le Dockerfile (`description`, `documentation`).
4. **Automatisation** : des scripts qui filtrent ou nettoient les images selon leurs labels (`--filter label=…`).
5. **Sécurité et licences** : retrouver les images construites à partir d'une image de base vulnérable (`base.name`, `base.digest`) et la licence du logiciel (`licenses`).
6. **Registres** : `ghcr.io` relie l'image à son dépôt GitHub grâce à `source`.

**En résumé** : les labels sont des « étiquettes de métadonnées » qui accompagnent vos images Docker pour les documenter et les rendre traçables ! 🏷️

---

## 12 – Laboratoires {#section-12}

### 12.1 – Laboratoire (durée 20 minutes) {#section-12-1}

<img src="../images/labo02.png" alt="" width="700" />

<br>

1. Afficher **tous** les labels de l'image officielle `nginx:1.27-alpine`, puis seulement son label `maintainer` (fonction `index`).
2. Construire une image à partir d'un Dockerfile qui contient `FROM nginx:1.27-alpine` et **aucune** directive `LABEL`. Quels labels porte-t-elle ? Pourquoi ?
3. Lister, avec un filtre, toutes les images de votre poste qui ont un label `maintainer`.
4. Démarrer un conteneur de votre image, puis le retrouver avec `docker ps --filter "label=maintainer"`.

---

### 12.2 – Laboratoire (durée 30 minutes) {#section-12-2}

<img src="../images/labo03.png" alt="" width="700" />

<br>

Reprendre le Dockerfile du **Formatif 01 – SuperMinou** (ou celui du laboratoire 4 du document [Dockerfile – Introduction](Dockerfile-Introduction.md)) et :

* Ajouter les labels OCI `title`, `description`, `authors`, `vendor` (« Cégep de Saint-Jérôme »), `licenses` (`MIT`), `source` (l'URL de votre dépôt GitHub) et `base.name`.
* Fournir `created`, `revision` et `version` au moment de la construction avec des `ARG`.
* Construire l'image `votrecompte/superminou:1.2` en passant la date UTC, le commit Git court et la version `1.2`.
* Afficher, avec `docker image inspect` et la fonction `index`, la **version** et le **commit** de l'image.
* Publier l'image sur Docker Hub, l'effacer du poste, la récupérer et vérifier que les labels ont voyagé avec elle.

---

### 12.3 – Laboratoire (durée 30 minutes) {#section-12-3}

<img src="../images/labo02.png" alt="" width="700" />

<br>

Une ancienne image utilise la convention `org.label-schema` :

```dockerfile
FROM alpine:3.20
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="Outils réseau" \
      org.label-schema.description="Boîte à outils : curl, dig, nc" \
      org.label-schema.version="0.9" \
      org.label-schema.vcs-url="https://github.com/user/outils-reseau" \
      org.label-schema.vcs-ref="1f2e3d4" \
      org.label-schema.vendor="Mon Entreprise" \
      org.label-schema.usage="https://github.com/user/outils-reseau#readme" \
      org.label-schema.docker.cmd="docker run -it outils-reseau sh"
RUN apk add --no-cache curl bind-tools netcat-openbsd
```

1. **Convertir** tous les labels vers la convention OCI à l'aide du tableau 04. Que faire des labels sans équivalent ?
2. Ajouter les labels OCI qui n'existaient pas dans label-schema (`authors`, `licenses`).
3. Écrire un fichier `docker-compose.yml` qui construit cette image avec un label d'**image** `ca.qc.cstj.cours: "420-4D4"` et un label de **conteneur** `ca.qc.cstj.equipe: "<votre nom>"`.
4. Démontrer, avec `docker image inspect` et `docker inspect <conteneur>`, où se trouve chacun des deux labels.

---

## Défi informatique

Écrire un script (bash ou PowerShell) qui affiche, pour **toutes** les images du poste, un tableau : nom de l'image, `org.opencontainers.image.version`, `org.opencontainers.image.created` et `org.opencontainers.image.source` (« — » si le label est absent).

---

## Références

- [OCI Image Format – Annotations](https://github.com/opencontainers/image-spec/blob/main/annotations.md) (clés prédéfinies et correspondance avec label-schema)
- [Docker – Object labels](https://docs.docker.com/engine/manage-resources/labels/) (règles de nommage)
- [Docker – Annotations](https://docs.docker.com/build/metadata/annotations/)
- [Dockerfile – LABEL](https://docs.docker.com/reference/dockerfile/#label)
- [docker/metadata-action](https://github.com/docker/metadata-action) (GitHub Actions)
- [Label Schema (archive)](https://github.com/label-schema/label-schema.org)

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2027*  
*Révision 2026.11.07.1*  

*Contenu par [VE2CUY](https://ve2cuy.github.io/blog/)*
