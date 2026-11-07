# 9 - Convention de nommage des labels

*Révision du 2026.11.07*

## Contenu

- [**1 – Qu'est-ce que `org.label-schema` ?**](#section-1)
- [**2 – Objectif**](#section-2)
- [**3 – Labels principaux**](#section-3)
- [**4 – Exemple pratique dans un Dockerfile**](#section-4)
- [**5 – Voir les labels d'une image**](#section-5)
- [**6 – Exemple dans docker-compose.yml**](#section-6)
- [**7 – Label-Schema vs OCI**](#section-7)
- [**8 – Exemple moderne (OCI)**](#section-8)
- [**9 – Cas d'usage**](#section-9)
- [**10 – Automatisation avec des variables**](#section-10)

---

## 1 – Qu'est-ce que `org.label-schema` ? {#section-1}

`org.label-schema` est une **convention de nommage standardisée** pour les labels (métadonnées) dans les images Docker. C'est un projet qui définit un schéma commun pour documenter les images de conteneurs.

## 2 – Objectif {#section-2}

Permettre à tous les créateurs d'images Docker d'utiliser les **mêmes clés de métadonnées** pour décrire leurs images, facilitant ainsi :
- L'automatisation
- La découverte d'informations
- La gestion des images
- L'audit et la conformité

## 3 – Labels principaux {#section-3}

Voici les labels les plus courants :

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

## 4 – Exemple pratique dans un Dockerfile {#section-4}

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

## 5 – Voir les labels d'une image {#section-5}

{% raw %}
```bash
# Inspecter les labels d'une image
docker inspect monapi:latest | jq '.[0].Config.Labels'

# Voir un label spécifique
docker inspect --format='{{.Config.Labels}}' monapi:latest

# Avec docker-compose
docker-compose config
```
{% endraw %}

## 6 – Exemple dans docker-compose.yml {#section-6}

```yaml
version: '3.8'

services:
  app:
    build: .
    image: monapi:2.1.5
    labels:
      org.label-schema.schema-version: "1.0"
      org.label-schema.name: "Mon API"
      org.label-schema.description: "API de production"
      org.label-schema.version: "2.1.5"
      org.label-schema.build-date: "2024-12-22"
      org.label-schema.vendor: "Mon Entreprise"
    ports:
      - "3000:3000"
```

## 7 – Label-Schema vs OCI {#section-7}

**⚠️ Note importante** : `org.label-schema` est maintenant **déprécié** (mais toujours largement utilisé).

Le standard moderne est **OCI Image Spec Annotations** :

| Ancien (label-schema) | Nouveau (OCI) |
|----------------------|---------------|
| `org.label-schema.version` | `org.opencontainers.image.version` |
| `org.label-schema.build-date` | `org.opencontainers.image.created` |
| `org.label-schema.vcs-url` | `org.opencontainers.image.source` |
| `org.label-schema.description` | `org.opencontainers.image.description` |

## 8 – Exemple moderne (OCI) {#section-8}

```dockerfile
LABEL org.opencontainers.image.created="2024-12-22T14:30:00Z" \
      org.opencontainers.image.authors="dev@monentreprise.com" \
      org.opencontainers.image.url="https://monapp.com" \
      org.opencontainers.image.documentation="https://docs.monapp.com" \
      org.opencontainers.image.source="https://github.com/user/repo" \
      org.opencontainers.image.version="2.1.5" \
      org.opencontainers.image.revision="a3f7b2c" \
      org.opencontainers.image.vendor="Mon Entreprise Inc." \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.title="Mon API REST" \
      org.opencontainers.image.description="API pour la gestion des utilisateurs"
```

## 9 – Cas d'usage {#section-9}

1. **CI/CD** : Tracer quelle version de code a généré une image
2. **Audit** : Savoir qui a créé l'image et quand
3. **Documentation** : Fournir des infos sans ouvrir le Dockerfile
4. **Automatisation** : Scripts qui lisent les métadonnées
5. **Sécurité** : Identifier rapidement les images vulnérables

## 10 – Automatisation avec des variables {#section-10}

```dockerfile
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.version="${VERSION}"
```

**Build avec variables :**
```bash
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) \
  --build-arg VERSION=2.1.5 \
  -t monapi:2.1.5 .
```

**En résumé** : Les labels sont comme des "tags de métadonnées" qui accompagnent vos images Docker pour les documenter et les rendre traçables ! 🏷️

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2027*  
*Révision 2026.11.07.1*  

*Contenu par [VE2CUY](https://ve2cuy.github.io/blog/)*
