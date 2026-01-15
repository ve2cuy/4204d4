# Introduction à Helm

Helm est le **gestionnaire de paquets** pour Kubernetes, comparable à `apt` pour Ubuntu ou `npm` pour Node.js. Il simplifie l'installation, la mise à jour et la gestion des applications Kubernetes.

## Pourquoi utiliser Helm ?

**Sans Helm**, pour déployer une application complexe comme WordPress :
- Vous devez créer et gérer 10-15 fichiers YAML (Deployment, Service, ConfigMap, Secret, PersistentVolumeClaim, etc.)
- Difficile de réutiliser la configuration pour différents environnements
- Complexe à mettre à jour ou à supprimer complètement

**Avec Helm**, une seule commande :
```bash
helm install mon-wordpress bitnami/wordpress
```

## Concepts de base

### 1. Chart
Un **Chart** est un package Helm. C'est un ensemble de fichiers qui décrivent une application Kubernetes complète.

Structure d'un Chart :
```
mon-chart/
├── Chart.yaml          # Métadonnées du chart
├── values.yaml         # Valeurs de configuration par défaut
├── templates/          # Templates de manifestes Kubernetes
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
└── charts/             # Dépendances (autres charts)
```

### 2. Repository
Un **Repository** est un dépôt qui contient des Charts, comme Docker Hub pour les images.

### 3. Release
Une **Release** est une instance déployée d'un Chart dans votre cluster.

## Installation de Helm

```bash
# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# macOS
brew install helm

# Windows (avec Chocolatey)
choco install kubernetes-helm

# Vérifier l'installation
helm version
```

## Commandes essentielles

### Ajouter un repository

```bash
# Ajouter le repository officiel de Helm
helm repo add stable https://charts.helm.sh/stable

# Ajouter le repository Bitnami (très populaire)
helm repo add bitnami https://charts.bitnami.com/bitnami

# Mettre à jour la liste des charts
helm repo update

# Lister les repositories
helm repo list
```

### Rechercher des Charts

```bash
# Rechercher un chart
helm search repo nginx

# Rechercher dans Artifact Hub (hub public)
helm search hub wordpress
```

### Installer un Chart

```bash
# Installation basique
helm install mon-nginx bitnami/nginx

# Installation avec un nom de release personnalisé
helm install mon-app bitnami/apache

# Installation dans un namespace spécifique
helm install mon-mysql bitnami/mysql --namespace database --create-namespace

# Voir les valeurs par défaut d'un chart
helm show values bitnami/nginx

# Installer avec des valeurs personnalisées
helm install mon-nginx bitnami/nginx --set service.type=LoadBalancer
```

### Lister les releases

```bash
# Lister toutes les releases installées
helm list

# Lister dans tous les namespaces
helm list --all-namespaces
```

### Obtenir des informations

```bash
# Voir le statut d'une release
helm status mon-nginx

# Voir les valeurs utilisées pour une release
helm get values mon-nginx

# Voir tous les manifestes déployés
helm get manifest mon-nginx
```

### Mettre à jour une release

```bash
# Mise à jour avec de nouvelles valeurs
helm upgrade mon-nginx bitnami/nginx --set replicaCount=3

# Mise à jour vers une nouvelle version du chart
helm upgrade mon-nginx bitnami/nginx --version 15.0.0
```

### Désinstaller une release

```bash
# Supprimer une release
helm uninstall mon-nginx

# Supprimer en gardant l'historique
helm uninstall mon-nginx --keep-history
```

### Rollback

```bash
# Voir l'historique des releases
helm history mon-nginx

# Revenir à une version précédente
helm rollback mon-nginx 1
```

## Exemples pratiques

### Exemple 1 : Installer WordPress avec MySQL

```bash
# Ajouter le repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Installer WordPress
helm install mon-blog bitnami/wordpress \
  --set wordpressUsername=admin \
  --set wordpressPassword=MonMotDePasse123 \
  --set service.type=LoadBalancer \
  --namespace blog \
  --create-namespace

# Vérifier l'installation
kubectl get all -n blog

# Obtenir l'URL d'accès
kubectl get svc -n blog mon-blog-wordpress
```

### Exemple 2 : Installer avec un fichier de valeurs personnalisées

Créez un fichier `mes-valeurs.yaml` :

```yaml
replicaCount: 3

image:
  repository: nginx
  tag: "1.25"

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

ingress:
  enabled: true
  hosts:
    - host: mon-site.exemple.com
      paths:
        - path: /
          pathType: Prefix
```

Installez avec ce fichier :

```bash
helm install mon-nginx bitnami/nginx -f mes-valeurs.yaml
```

### Exemple 3 : Installer Traefik avec Helm

```bash
# Ajouter le repository Traefik
helm repo add traefik https://traefik.github.io/charts
helm repo update

# Créer un fichier de configuration
cat > traefik-values.yaml << EOF
# Activer le dashboard
dashboard:
  enabled: true

# Ports
ports:
  web:
    port: 80
  websecure:
    port: 443

# Service LoadBalancer
service:
  type: LoadBalancer

# Logs
logs:
  general:
    level: INFO
EOF

# Installer Traefik
helm install traefik traefik/traefik \
  -f traefik-values.yaml \
  --namespace traefik \
  --create-namespace

# Vérifier l'installation
helm status traefik -n traefik
kubectl get all -n traefik
```

### Exemple 4 : Mettre à jour une configuration

```bash
# Modifier la configuration
helm upgrade traefik traefik/traefik \
  --namespace traefik \
  --set logs.general.level=DEBUG \
  --reuse-values

# Ou avec un nouveau fichier de valeurs
helm upgrade traefik traefik/traefik \
  -f traefik-values-prod.yaml \
  --namespace traefik
```

### Exemple 5 : Créer votre propre Chart

```bash
# Créer la structure d'un chart
helm create mon-application

# Structure créée :
# mon-application/
# ├── Chart.yaml
# ├── values.yaml
# ├── templates/
# │   ├── deployment.yaml
# │   ├── service.yaml
# │   └── ...

# Modifier les templates selon vos besoins
# Puis installer
helm install ma-release ./mon-application

# Ou packager le chart
helm package mon-application
# Crée : mon-application-0.1.0.tgz

# Installer depuis le package
helm install ma-release mon-application-0.1.0.tgz
```

## Template de base pour un Chart personnalisé

**Chart.yaml**
```yaml
apiVersion: v2
name: mon-app
description: Ma première application Helm
version: 0.1.0
appVersion: "1.0"
```

**values.yaml**
```yaml
replicaCount: 2

image:
  repository: nginx
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

env:
  - name: ENVIRONMENT
    value: "production"
```

**templates/deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: app
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 80
        env:
        {{- range .Values.env }}
        - name: {{ .name }}
          value: {{ .value | quote }}
        {{- end }}
```

## Bonnes pratiques

1. **Toujours spécifier les versions** : `helm install app bitnami/nginx --version 15.0.0`
2. **Utiliser des fichiers de valeurs** plutôt que de multiples `--set`
3. **Tester avant d'installer** : `helm install --dry-run --debug`
4. **Documenter vos valeurs** dans `values.yaml`
5. **Versionner vos Charts personnalisés**
6. **Utiliser des namespaces** pour isoler les applications

## Commandes de débogage

```bash
# Simuler une installation sans l'exécuter
helm install mon-app bitnami/nginx --dry-run --debug

# Valider les templates
helm lint mon-chart/

# Afficher les templates rendus
helm template mon-app bitnami/nginx

# Vérifier les différences avant un upgrade
helm diff upgrade mon-app bitnami/nginx --values new-values.yaml
```

## Résumé des commandes les plus utilisées

```bash
# Gestion des repositories
helm repo add <nom> <url>
helm repo update
helm repo list

# Installation et gestion
helm install <release> <chart>
helm list
helm status <release>
helm upgrade <release> <chart>
helm uninstall <release>
helm rollback <release> <revision>

# Information
helm show values <chart>
helm show chart <chart>
helm get values <release>

# Recherche
helm search repo <terme>
helm search hub <terme>
```


Helm simplifie la gestion des applications Kubernetes en permettant de déployer des stacks complètes avec une seule commande, tout en offrant la flexibilité de personnaliser chaque aspect de la configuration.