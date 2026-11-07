# 21 - Projet Complet : CI/CD avec GitHub Actions et Docker Hub

*Révision du 2026.11.07*

## Contenu

- [**Vue d'ensemble du projet**](#section-vue-d-ensemble-du-projet)
- [**Structure du projet**](#section-structure-du-projet)
- [**Étape 1 : Créer l'application**](#section-1)
- [**Étape 2 : Créer le Dockerfile**](#section-2)
- [**Étape 3 : Configuration GitHub Actions**](#section-3)
- [**Étape 4 : Docker Compose pour tests locaux**](#section-4)
- [**Étape 5 : Documentation**](#section-5)
- [**Étape 6 : Configuration GitHub**](#section-6)
  - [6.1 – Créer le repository](#section-6-1)
  - [6.2 – Configurer les secrets](#section-6-2)
- [**Étape 7 : Utilisation**](#section-7)
- [**🎯 Résultat final**](#section-resultat-final)

---

## Vue d'ensemble du projet {#section-vue-d-ensemble-du-projet}

Nous allons créer une application web "SuperMinou v2" avec :
- Une application PHP/Apache
- Build automatique avec GitHub Actions
- Publication sur Docker Hub
- Versioning automatique
- Tests de qualité

## Structure du projet {#section-structure-du-projet}

```
superminou-v2/
|-- .github/
|   `-- workflows/
|       |-- docker-build-push.yml      # Workflow principal
|       `-- docker-release.yml         # Workflow pour les releases
|-- src/
|   |-- index.php                      # Page principale
|   |-- about.php                      # Page à propos
|   |-- css/
|   |   `-- style.css                  # Styles
|   `-- images/
|       `-- superminou.png             # Logo
|-- tests/
|   `-- test.sh                        # Tests de validation
|-- Dockerfile                         # Définition de l'image
|-- .dockerignore                      # Fichiers à exclure
|-- docker-compose.yml                 # Pour tester localement
`-- README.md                          # Documentation
```

## Étape 1 : Créer l'application {#section-1}

### Fichier : `src/index.php`

```php
<?php
$hostname = gethostname();
$version = getenv('APP_VERSION') ?: 'dev';
$build_date = getenv('BUILD_DATE') ?: date('Y-m-d');
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SuperMinou v2</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header>
        <h1>🐱 SuperMinou v2</h1>
        <p class="subtitle">Application de démonstration CI/CD</p>
    </header>
    
    <main>
        <div class="card">
            <h2>Bienvenue sur SuperMinou!</h2>
            <p>Cette application démontre l'utilisation de GitHub Actions pour automatiser le build et le déploiement d'images Docker.</p>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <h3>🖥️ Serveur</h3>
                <p><strong>Hostname:</strong> <?php echo htmlspecialchars($hostname); ?></p>
            </div>
            
            <div class="info-card">
                <h3>📦 Version</h3>
                <p><strong>Version:</strong> <?php echo htmlspecialchars($version); ?></p>
            </div>
            
            <div class="info-card">
                <h3>📅 Build</h3>
                <p><strong>Date:</strong> <?php echo htmlspecialchars($build_date); ?></p>
            </div>
            
            <div class="info-card">
                <h3>⏰ Heure</h3>
                <p><strong>Serveur:</strong> <?php echo date('H:i:s'); ?></p>
            </div>
        </div>
        
        <div class="card">
            <h3>📊 Informations du serveur</h3>
            <ul>
                <li><strong>PHP Version:</strong> <?php echo phpversion(); ?></li>
                <li><strong>Server Software:</strong> <?php echo $_SERVER['SERVER_SOFTWARE']; ?></li>
                <li><strong>Document Root:</strong> <?php echo $_SERVER['DOCUMENT_ROOT']; ?></li>
            </ul>
        </div>
        
        <div class="links">
            <a href="about.php" class="btn">À propos</a>
            <a href="https://github.com/votre-username/superminou-v2" class="btn btn-secondary">GitHub</a>
        </div>
    </main>
    
    <footer>
        <p>© 2024 SuperMinou | Propulsé par Docker & GitHub Actions</p>
    </footer>
</body>
</html>
```

### Fichier : `src/about.php`

```php
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>À propos - SuperMinou v2</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <header>
        <h1>🐱 À propos de SuperMinou</h1>
    </header>
    
    <main>
        <div class="card">
            <h2>Projet de démonstration CI/CD</h2>
            <p>SuperMinou v2 est une application web construite pour démontrer les meilleures pratiques de CI/CD avec GitHub Actions et Docker Hub.</p>
            
            <h3>🎯 Objectifs du projet</h3>
            <ul>
                <li>Automatiser la construction d'images Docker</li>
                <li>Publier automatiquement sur Docker Hub</li>
                <li>Gérer le versioning avec des tags Git</li>
                <li>Implémenter des tests automatisés</li>
                <li>Démontrer les bonnes pratiques DevOps</li>
            </ul>
            
            <h3>🛠️ Technologies utilisées</h3>
            <ul>
                <li>PHP 8.2 avec Apache</li>
                <li>Docker & Docker Compose</li>
                <li>GitHub Actions</li>
                <li>Docker Hub</li>
            </ul>
        </div>
        
        <div class="links">
            <a href="index.php" class="btn">Retour</a>
        </div>
    </main>
    
    <footer>
        <p>© 2024 SuperMinou | Propulsé par Docker & GitHub Actions</p>
    </footer>
</body>
</html>
```

### Fichier : `src/css/style.css`

```css
:root {
    --primary-color: #dc143c;
    --secondary-color: #333;
    --background: #f5f5f5;
    --card-background: white;
    --text-color: #333;
    --border-radius: 10px;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: var(--background);
    color: var(--text-color);
    line-height: 1.6;
}

header {
    background: linear-gradient(135deg, var(--primary-color), #ff6b6b);
    color: white;
    padding: 2rem;
    text-align: center;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

header h1 {
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
}

.subtitle {
    font-size: 1.2rem;
    opacity: 0.9;
}

main {
    max-width: 1200px;
    margin: 2rem auto;
    padding: 0 2rem;
}

.card {
    background: var(--card-background);
    border-radius: var(--border-radius);
    padding: 2rem;
    margin-bottom: 2rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.card h2 {
    color: var(--primary-color);
    margin-bottom: 1rem;
}

.card h3 {
    color: var(--secondary-color);
    margin-top: 1.5rem;
    margin-bottom: 1rem;
}

.card ul {
    list-style: none;
    padding-left: 0;
}

.card ul li {
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
}

.card ul li:last-child {
    border-bottom: none;
}

.info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-bottom: 2rem;
}

.info-card {
    background: var(--card-background);
    border-radius: var(--border-radius);
    padding: 1.5rem;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    text-align: center;
    transition: transform 0.3s ease;
}

.info-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.15);
}

.info-card h3 {
    color: var(--primary-color);
    margin: 0 0 1rem 0;
    font-size: 1.2rem;
}

.info-card p {
    margin: 0.5rem 0;
}

.links {
    display: flex;
    gap: 1rem;
    justify-content: center;
    flex-wrap: wrap;
}

.btn {
    display: inline-block;
    padding: 0.8rem 2rem;
    background: var(--primary-color);
    color: white;
    text-decoration: none;
    border-radius: 5px;
    font-weight: bold;
    transition: background 0.3s ease;
}

.btn:hover {
    background: #b01030;
}

.btn-secondary {
    background: var(--secondary-color);
}

.btn-secondary:hover {
    background: #555;
}

footer {
    text-align: center;
    padding: 2rem;
    color: #666;
    margin-top: 4rem;
}

@media (max-width: 768px) {
    header h1 {
        font-size: 2rem;
    }
    
    .info-grid {
        grid-template-columns: 1fr;
    }
    
    main {
        padding: 0 1rem;
    }
}
```

## Étape 2 : Créer le Dockerfile {#section-2}

### Fichier : `Dockerfile`

```dockerfile
# Utiliser l'image PHP officielle avec Apache
FROM php:8.2-apache

# Métadonnées de l'image
LABEL maintainer="votre-email@example.com"
LABEL description="SuperMinou v2 - Application de démonstration CI/CD"

# Arguments de build (définis par GitHub Actions)
ARG APP_VERSION=dev
ARG BUILD_DATE=unknown
ARG VCS_REF=unknown

# Variables d'environnement
ENV APP_VERSION=${APP_VERSION} \
    BUILD_DATE=${BUILD_DATE} \
    VCS_REF=${VCS_REF} \
    APACHE_DOCUMENT_ROOT=/var/www/html

# Installer les dépendances système si nécessaire
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    && docker-php-ext-install zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurer Apache
RUN a2enmod rewrite

# Copier les fichiers de l'application
COPY src/ ${APACHE_DOCUMENT_ROOT}/

# Définir les permissions appropriées
RUN chown -R www-data:www-data ${APACHE_DOCUMENT_ROOT} \
    && chmod -R 755 ${APACHE_DOCUMENT_ROOT}

# Exposer le port 80
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Commande par défaut
CMD ["apache2-foreground"]
```

### Fichier : `.dockerignore`

```
.git
.github
.gitignore
README.md
.dockerignore
docker-compose.yml
tests/
*.md
.env
.DS_Store
node_modules
```

## Étape 3 : Configuration GitHub Actions {#section-3}

### Fichier : `.github/workflows/docker-build-push.yml`

{% raw %}
```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main
      - develop
    paths:
      - 'src/**'
      - 'Dockerfile'
      - '.github/workflows/docker-build-push.yml'
  pull_request:
    branches:
      - main
  workflow_dispatch:

env:
  DOCKER_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/superminou-v2
  PLATFORMS: linux/amd64,linux/arm64

jobs:
  # Job 1 : Tests et validation
  test:
    name: Tests et Validation
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Lint Dockerfile
        uses: hadolint/hadolint-action@v3.1.0
        with:
          dockerfile: Dockerfile
          failure-threshold: warning

      - name: Build test image
        uses: docker/setup-buildx-action@v3

      - name: Build image pour tests
        uses: docker/build-push-action@v5
        with:
          context: .
          load: true
          tags: ${{ env.DOCKER_IMAGE }}:test
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Test de l'image
        run: |
          echo "🧪 Démarrage des tests..."
          
          # Démarrer le conteneur
          docker run -d --name test-container -p 8080:80 ${{ env.DOCKER_IMAGE }}:test
          
          # Attendre que le serveur soit prêt
          sleep 5
          
          # Test 1: Vérifier que le serveur répond
          echo "Test 1: Vérification du serveur..."
          curl -f http://localhost:8080/ || exit 1
          
          # Test 2: Vérifier le code de statut HTTP
          echo "Test 2: Vérification du code HTTP..."
          STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/)
          if [ "$STATUS" != "200" ]; then
            echo "❌ Erreur: Code HTTP $STATUS au lieu de 200"
            exit 1
          fi
          
          # Test 3: Vérifier le contenu
          echo "Test 3: Vérification du contenu..."
          curl -s http://localhost:8080/ | grep -q "SuperMinou" || exit 1
          
          # Test 4: Vérifier la page about
          echo "Test 4: Vérification de la page About..."
          curl -f http://localhost:8080/about.php || exit 1
          
          echo "✅ Tous les tests sont passés!"
          
          # Arrêter et supprimer le conteneur
          docker stop test-container
          docker rm test-container

      - name: Scan de sécurité avec Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ env.DOCKER_IMAGE }}:test
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results
        uses: github/codeql-action/upload-sarif@v3
        if: always()
        with:
          sarif_file: 'trivy-results.sarif'

  # Job 2 : Build et Push
  build-and-push:
    name: Build et Push vers Docker Hub
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Pour avoir l'historique Git complet

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
          images: ${{ env.DOCKER_IMAGE }}
          tags: |
            type=ref,event=branch
            type=sha,prefix={{branch}}-
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: ${{ env.PLATFORMS }}
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          build-args: |
            APP_VERSION=${{ github.ref_name }}
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            VCS_REF=${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Update Docker Hub description
        uses: peter-evans/dockerhub-description@v4
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
          repository: ${{ env.DOCKER_IMAGE }}
          short-description: ${{ github.event.repository.description }}
          readme-filepath: ./README.md

      - name: Summary
        run: |
          echo "## 🎉 Build réussi!" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "📦 **Image:** \`${{ env.DOCKER_IMAGE }}\`" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "🏷️ **Tags:**" >> $GITHUB_STEP_SUMMARY
          echo "\`\`\`" >> $GITHUB_STEP_SUMMARY
          echo "${{ steps.meta.outputs.tags }}" >> $GITHUB_STEP_SUMMARY
          echo "\`\`\`" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "🔗 [Voir sur Docker Hub](https://hub.docker.com/r/${{ env.DOCKER_IMAGE }})" >> $GITHUB_STEP_SUMMARY
```
{% endraw %}

### Fichier : `.github/workflows/docker-release.yml`

{% raw %}
```yaml
name: Release Docker Image

on:
  push:
    tags:
      - 'v*.*.*'

env:
  DOCKER_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/superminou-v2

jobs:
  release:
    name: Build et Release
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
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

      - name: Extract version from tag
        id: version
        run: |
          VERSION=${GITHUB_REF#refs/tags/v}
          echo "VERSION=$VERSION" >> $GITHUB_OUTPUT
          echo "MAJOR=$(echo $VERSION | cut -d. -f1)" >> $GITHUB_OUTPUT
          echo "MINOR=$(echo $VERSION | cut -d. -f1-2)" >> $GITHUB_OUTPUT

      - name: Build and push release
        uses: docker/build-push-action@v5
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          tags: |
            ${{ env.DOCKER_IMAGE }}:${{ steps.version.outputs.VERSION }}
            ${{ env.DOCKER_IMAGE }}:${{ steps.version.outputs.MINOR }}
            ${{ env.DOCKER_IMAGE }}:${{ steps.version.outputs.MAJOR }}
            ${{ env.DOCKER_IMAGE }}:latest
          build-args: |
            APP_VERSION=${{ steps.version.outputs.VERSION }}
            BUILD_DATE=${{ github.event.head_commit.timestamp }}
            VCS_REF=${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          generate_release_notes: true
          body: |
            ## 🐱 SuperMinou v${{ steps.version.outputs.VERSION }}
            
            ### 📦 Image Docker
            ```bash
            docker pull ${{ env.DOCKER_IMAGE }}:${{ steps.version.outputs.VERSION }}
            ```
{% endraw %}
            
            ### 🚀 Utilisation
            {% raw %}
            ```bash
            docker run -p 8080:80 ${{ env.DOCKER_IMAGE }}:${{ steps.version.outputs.VERSION }}
            ```
            {% endraw %}
            
            Puis ouvrir http://localhost:8080
```

## Étape 4 : Docker Compose pour tests locaux {#section-4}

### Fichier : `docker-compose.yml`

```yaml
services:
  web:
    build:
      context: .
      args:
        APP_VERSION: local-dev
        BUILD_DATE: ${BUILD_DATE:-unknown}
    ports:
      - "8080:80"
    volumes:
      # Pour le développement, monter le code source
      - ./src:/var/www/html
    environment:
      - APP_VERSION=local-dev
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/"]
      interval: 30s
      timeout: 3s
      retries: 3
```

## Étape 5 : Documentation {#section-5}

### Fichier : `README.md`

````markdown
# 🐱 SuperMinou v2

Application de démonstration pour CI/CD avec GitHub Actions et Docker Hub.

## 🚀 Démarrage rapide

### Utiliser l'image Docker Hub

```bash
# Télécharger et exécuter l'image
docker run -p 8080:80 votre-username/superminou-v2:latest

# Ouvrir dans le navigateur
open http://localhost:8080
```

### Build local

```bash
# Cloner le repo
git clone https://github.com/votre-username/superminou-v2.git
cd superminou-v2

# Build avec Docker Compose
docker compose up --build

# Ou build manuel
docker build -t superminou-v2 .
docker run -p 8080:80 superminou-v2
```

## 📦 Images disponibles

| Tag | Description |
|-----|-------------|
| `latest` | Dernière version stable |
| `main` | Branche principale |
| `v1.2.3` | Version spécifique |
| `1.2` | Version mineure |
| `1` | Version majeure |

## 🛠️ Développement

### Prérequis

- Docker & Docker Compose
- Git
- Compte Docker Hub
- Compte GitHub

### Configuration GitHub Actions

1. Créer un Access Token sur Docker Hub
2. Ajouter les secrets dans GitHub:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`
3. Push vers `main` pour déclencher le build

### Structure

```
superminou-v2/
|-- .github/workflows/    # GitHub Actions
|-- src/                  # Code source
|-- Dockerfile           # Définition image
`-- docker-compose.yml   # Composition locale
```

## 📝 Versioning

Pour créer une nouvelle release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

Cela déclenche automatiquement:
- Build de l'image
- Publication sur Docker Hub
- Création d'une GitHub Release

## 🧪 Tests

Les tests sont automatiquement exécutés par GitHub Actions:
- Lint du Dockerfile
- Build de l'image
- Tests fonctionnels
- Scan de sécurité avec Trivy

## 📄 License

MIT License

## 👤 Auteur

Votre Nom - [@votre-username](https://github.com/votre-username)
````

## Étape 6 : Configuration GitHub {#section-6}

### 6.1 – Créer le repository {#section-6-1}

```bash
# Initialiser Git
git init
git add .
git commit -m "Initial commit: SuperMinou v2"

# Ajouter le remote GitHub
git remote add origin https://github.com/votre-username/superminou-v2.git
git branch -M main
git push -u origin main
```

### 6.2 – Configurer les secrets {#section-6-2}

1. Aller sur Docker Hub → Account Settings → Security
2. Créer un Access Token
3. Sur GitHub → Settings → Secrets and variables → Actions
4. Ajouter:
   - `DOCKERHUB_USERNAME`: votre username
   - `DOCKERHUB_TOKEN`: le token créé

## Étape 7 : Utilisation {#section-7}

### Premier build

```bash
# Push vers main déclenche automatiquement le workflow
git push origin main

# Aller dans l'onglet "Actions" pour voir le build
```

### Créer une release

```bash
# Créer et pusher un tag
git tag v1.0.0
git push origin v1.0.0

# Le workflow "Release" se déclenche automatiquement
```

### Tester l'image publiée

```bash
# Pull depuis Docker Hub
docker pull votre-username/superminou-v2:latest

# Exécuter
docker run -p 8080:80 votre-username/superminou-v2:latest

# Ouvrir http://localhost:8080
```

## 🎯 Résultat final {#section-resultat-final}

Après avoir suivi ce guide, vous aurez:

✅ Une application web complète
✅ Build automatique sur chaque push
✅ Tests automatisés
✅ Scan de sécurité
✅ Publication sur Docker Hub
✅ Versioning sémantique
✅ Support multi-architecture (amd64, arm64)
✅ GitHub Releases automatiques
✅ Documentation complète

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Hub](https://hub.docker.com)
- [Semantic Versioning](https://semver.org)

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2027*  
*Révision 2026.11.07.1*  

*Contenu par [VE2CUY](https://ve2cuy.github.io/blog/)*
