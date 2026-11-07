# 20 - GitHub Action : Build et Push vers Docker Hub

## Contenu

- [**1. Prérequis**](#section-1)
  - [A. Créer un compte Docker Hub](#section-1-a)
  - [B. Créer un Access Token Docker Hub](#section-1-b)
  - [C. Ajouter les secrets dans GitHub](#section-1-c)
- [**2. Workflow de base (`.github/workflows/docker-build.yml`)**](#section-2)
- [**3. Workflow avec plusieurs Dockerfiles**](#section-3)
- [**4. Workflow avancé avec tests**](#section-4)
- [**5. Workflow déclenché par tags (versioning)**](#section-5)
- [**6. Exemple avec build arguments**](#section-6)
- [**7. Structure de projet recommandée**](#section-7)
- [**8. Fichier .dockerignore recommandé**](#section-8)
- [**9. Utilisation après déploiement**](#section-9)
- [**10. Exemple complet pour SuperMinou**](#section-10)
- [**11. Troubleshooting**](#section-11)
- [**12. Commandes utiles**](#section-12)

---

## 1. Prérequis {#section-1}

### A. Créer un compte Docker Hub {#section-1-a}
- Allez sur [hub.docker.com](https://hub.docker.com)
- Créez un compte si nécessaire
- Notez votre **username Docker Hub**

### B. Créer un Access Token Docker Hub {#section-1-b}
1. Connectez-vous à Docker Hub
2. Allez dans **Account Settings** → **Security**
3. Cliquez sur **New Access Token**
4. Donnez un nom (ex: `github-actions`)
5. Permissions : **Read, Write, Delete**
6. Copiez le token généré (vous ne pourrez plus le voir après)

### C. Ajouter les secrets dans GitHub {#section-1-c}
1. Allez dans votre repo GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Cliquez sur **New repository secret**
4. Ajoutez deux secrets :
   - `DOCKERHUB_USERNAME` : votre username Docker Hub
   - `DOCKERHUB_TOKEN` : le token d'accès créé

## 2. Workflow de base (`.github/workflows/docker-build.yml`) {#section-2}

{% raw %}
```yaml
name: Build et Push Docker Image

on:
  push:
    branches: [ "main" ]
    tags:
      - 'v*'
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKERHUB_USERNAME }}/mon-image
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=registry,ref=${{ secrets.DOCKERHUB_USERNAME }}/mon-image:buildcache
          cache-to: type=registry,ref=${{ secrets.DOCKERHUB_USERNAME }}/mon-image:buildcache,mode=max
```
{% endraw %}

## 3. Workflow avec plusieurs Dockerfiles {#section-3}

{% raw %}
```yaml
name: Build Multiple Docker Images

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  build-superminou:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push SuperMinou
        uses: docker/build-push-action@v5
        with:
          context: ./superminou
          file: ./superminou/Dockerfile
          push: true
          tags: |
            ${{ secrets.DOCKERHUB_USERNAME }}/superminou:latest
            ${{ secrets.DOCKERHUB_USERNAME }}/superminou:${{ github.sha }}

  build-autre-app:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push Autre App
        uses: docker/build-push-action@v5
        with:
          context: ./autre-app
          file: ./autre-app/Dockerfile
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/autre-app:latest
```
{% endraw %}

## 4. Workflow avancé avec tests {#section-4}

{% raw %}
```yaml
name: Build, Test et Push Docker Image

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

env:
  IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/mon-app

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Build image pour test
        uses: docker/build-push-action@v5
        with:
          context: .
          load: true
          tags: ${{ env.IMAGE_NAME }}:test
      
      - name: Test de l'image
        run: |
          docker run --rm ${{ env.IMAGE_NAME }}:test echo "Test réussi"
          # Ajoutez d'autres tests ici
      
      - name: Scan de sécurité avec Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.IMAGE_NAME }}:test
          format: 'table'
          exit-code: '1'
          ignore-unfixed: true
          severity: 'CRITICAL,HIGH'

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: Build and push multi-platform
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```
{% endraw %}

## 5. Workflow déclenché par tags (versioning) {#section-5}

{% raw %}
```yaml
name: Release Docker Image

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Extract version from tag
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT
      
      - name: Build and push avec version
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ secrets.DOCKERHUB_USERNAME }}/mon-app:${{ steps.version.outputs.VERSION }}
            ${{ secrets.DOCKERHUB_USERNAME }}/mon-app:latest
      
      - name: Update Docker Hub description
        uses: peter-evans/dockerhub-description@v4
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
          repository: ${{ secrets.DOCKERHUB_USERNAME }}/mon-app
          readme-filepath: ./README.md
```
{% endraw %}

## 6. Exemple avec build arguments {#section-6}

{% raw %}
```yaml
name: Build avec Arguments

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push avec arguments
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKERHUB_USERNAME }}/mon-app:latest
          build-args: |
            VERSION=${{ github.sha }}
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            ENVIRONMENT=production
```
{% endraw %}

## 7. Structure de projet recommandée {#section-7}

```
mon-projet/
├── .github/
│   └── workflows/
│       └── docker-build.yml
├── app1/
│   ├── Dockerfile
│   └── src/
├── app2/
│   ├── Dockerfile
│   └── src/
├── .dockerignore
└── README.md
```

## 8. Fichier .dockerignore recommandé {#section-8}

```
.git
.github
.gitignore
README.md
.dockerignore
.env
.vscode
node_modules
*.log
.DS_Store
```

## 9. Utilisation après déploiement {#section-9}

Une fois l'image publiée, vous pouvez la télécharger :

```bash
# Pull l'image
docker pull votre-username/mon-app:latest

# Ou avec une version spécifique
docker pull votre-username/mon-app:v1.2.3

# Exécuter l'image
docker run -p 8080:80 votre-username/mon-app:latest
```

## 10. Exemple complet pour SuperMinou {#section-10}

{% raw %}
```yaml
name: Build SuperMinou

on:
  push:
    branches: [ "main" ]
    paths:
      - 'superminou/**'
      - '.github/workflows/superminou.yml'

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      
      - name: Build and push SuperMinou
        uses: docker/build-push-action@v5
        with:
          context: ./superminou
          file: ./superminou/Dockerfile
          push: true
          tags: |
            ${{ secrets.DOCKERHUB_USERNAME }}/superminou:latest
            ${{ secrets.DOCKERHUB_USERNAME }}/superminou:semaine08-labo2
          build-args: |
            PHP_VERSION=8.0.3
```
{% endraw %}

## 11. Troubleshooting {#section-11}

### Erreur d'authentification
```bash
# Vérifiez que les secrets sont bien configurés
# Settings → Secrets → Actions
```

### Image trop grosse
```dockerfile
# Utilisez des images Alpine
FROM php:8.0-apache-alpine

# Multi-stage builds
FROM node:18 AS builder
# ... build steps
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

### Cache qui ne fonctionne pas
```yaml
# Utilisez GitHub Actions cache
cache-from: type=gha
cache-to: type=gha,mode=max
```

## 12. Commandes utiles {#section-12}

```bash
# Tester localement le workflow
act push -s DOCKERHUB_USERNAME=xxx -s DOCKERHUB_TOKEN=xxx

# Voir les logs GitHub Actions
# Allez dans l'onglet "Actions" de votre repo

# Lister vos images sur Docker Hub
docker search votre-username
```

## 📚 Ressources

- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Login Action](https://github.com/docker/login-action)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2026*  
*Révision 2026.11.07.1*  

*Contenu par [VE2CUY](https://ve2cuy.github.io/blog/)*
