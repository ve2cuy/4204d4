# Guide des Manifestes Kubernetes

## Qu'est-ce qu'un Manifeste Kubernetes ?

Un **manifeste Kubernetes** est un fichier YAML qui décrit l'état désiré d'une ressource. Structure commune :

```yaml
apiVersion: # Version de l'API
kind:       # Type de ressource
metadata:   # Nom, labels, annotations
spec:       # Spécification (état désiré)
```

---

## 1. Pod

### À quoi ça sert ?
Le **Pod** est la plus petite unité déployable. Un groupe de conteneurs partageant réseau et stockage.

### Exemple commenté

```yaml
# Version de l'API pour les Pods
apiVersion: v1
kind: Pod

# ============================================================
# METADATA : Informations sur le Pod
# ============================================================
metadata:
  name: mon-pod-nginx              # Nom unique
  namespace: default               # Namespace (défaut: default)
  labels:                          # Labels pour sélection
    app: nginx
    version: "1.0"
  annotations:                     # Métadonnées additionnelles
    description: "Pod de démonstration"

# ============================================================
# SPEC : Spécification du Pod
# ============================================================
spec:
  # Liste des conteneurs
  containers:
  - name: nginx-container          # Nom du conteneur
    image: nginx:1.21              # Image Docker
    imagePullPolicy: IfNotPresent  # Always | IfNotPresent | Never
    
    # Ports exposés
    ports:
    - containerPort: 80            # Port du conteneur
      name: http
      protocol: TCP
    
    # Variables d'environnement
    env:
    - name: NGINX_HOST
      value: "example.com"
    
    # Ressources CPU/Mémoire
    resources:
      requests:                    # Minimum garanti
        memory: "64Mi"
        cpu: "250m"                # 250 milliCPU = 0.25 CPU
      limits:                      # Maximum autorisé
        memory: "128Mi"
        cpu: "500m"
    
    # Probes de santé
    livenessProbe:                 # Vérifie si le conteneur est vivant
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 30      # Attendre avant premier test
      periodSeconds: 10            # Fréquence des tests
    
    readinessProbe:                # Vérifie si prêt pour le trafic
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
    
    # Montage de volumes
    volumeMounts:
    - name: config-volume
      mountPath: /etc/nginx/conf.d
      readOnly: true
  
  # Volumes disponibles
  volumes:
  - name: config-volume
    configMap:
      name: nginx-config
  
  # Politique de redémarrage
  restartPolicy: Always            # Always | OnFailure | Never
```

---

## 2. Deployment

### À quoi ça sert ?
Le **Deployment** gère les Pods : réplication, mises à jour progressives, rollback, auto-guérison.

### Exemple commenté

```yaml
apiVersion: apps/v1
kind: Deployment

# ============================================================
# METADATA : Informations sur le Deployment
# ============================================================
metadata:
  name: deploy-nginx
  namespace: production
  labels:
    app: nginx

# ============================================================
# SPEC NIVEAU 1 : Configuration du Deployment
# ============================================================
spec:
  replicas: 3                      # Nombre de Pods à maintenir
  
  # Sélecteur : identifie les Pods gérés
  selector:
    matchLabels:
      app: nginx                   # DOIT correspondre aux labels du template
  
  # Stratégie de mise à jour
  strategy:
    type: RollingUpdate            # RollingUpdate | Recreate
    rollingUpdate:
      maxUnavailable: 1            # Max de Pods indisponibles
      maxSurge: 1                  # Max de Pods supplémentaires
  
  revisionHistoryLimit: 10         # Historique pour rollback
  minReadySeconds: 5               # Temps avant "prêt"

  # ============================================================
  # TEMPLATE : Définition des Pods (comme un manifeste Pod)
  # ============================================================
  template:
    metadata:
      labels:
        app: nginx                 # Labels des Pods créés
        version: v1
    
    # ============================================================
    # SPEC NIVEAU 2 : Spécification des Pods
    # ============================================================
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - name: http
          containerPort: 80
        
        # Variables depuis ConfigMap
        env:
        - name: CONFIG_VALUE
          valueFrom:
            configMapKeyRef:
              name: app-config     # Nom du ConfigMap
              key: config.property # Clé dans le ConfigMap
        
        # Variables depuis Secret
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-secret      # Nom du Secret
              key: password        # Clé dans le Secret
        
        # Importer toutes les vars d'un ConfigMap
        envFrom:
        - configMapRef:
            name: app-env-config
        
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        
        livenessProbe:
          httpGet:
            path: /healthz
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
          failureThreshold: 3      # Échecs avant redémarrage
        
        readinessProbe:
          httpGet:
            path: /ready
            port: http
          successThreshold: 1      # Succès pour "prêt"
        
        volumeMounts:
        - name: config
          mountPath: /etc/nginx/conf.d
      
      # Conteneur d'initialisation (exécuté avant les autres)
      initContainers:
      - name: init-config
        image: busybox
        command: ['sh', '-c', 'echo "Init..." && sleep 5']
      
      # Volumes
      volumes:
      - name: config
        configMap:
          name: nginx-config
```

---

## 3. ConfigMap

### À quoi ça sert ?
Le **ConfigMap** stocke des données de configuration non sensibles (fichiers, variables).

### Exemple commenté

```yaml
apiVersion: v1
kind: ConfigMap

# ============================================================
# METADATA
# ============================================================
metadata:
  name: app-config
  namespace: default
  labels:
    app: mon-application

# ============================================================
# DATA : Données de configuration
# ============================================================
data:
  # Variables simples (clé: valeur)
  app.name: "SuperMinou"
  app.version: "2.0.0"
  database.host: "mysql-service"
  database.port: "3306"
  
  # Fichiers de configuration complets
  # Format: nom-fichier: |
  #   contenu multiligne
  nginx.conf: |
    server {
        listen 80;
        server_name example.com;
        
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
        
        location /api {
            proxy_pass http://api-service:8080;
        }
    }
  
  # Configuration PHP
  php.ini: |
    [PHP]
    max_execution_time = 30
    memory_limit = 128M
    upload_max_filesize = 10M
    
    [Date]
    date.timezone = "America/Montreal"
  
  # Configuration JSON
  config.json: |
    {
      "api": {
        "endpoint": "https://api.example.com",
        "timeout": 5000
      },
      "cache": {
        "enabled": true,
        "ttl": 3600
      }
    }
  
  # Script shell
  startup.sh: |
    #!/bin/bash
    echo "Starting application..."
    until nc -z $DB_HOST $DB_PORT; do
      echo "Waiting for database..."
      sleep 2
    done
    echo "Database ready!"

# ============================================================
# UTILISATION dans un Pod
# ============================================================
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-configmap
spec:
  containers:
  - name: app
    image: myapp
    
    # Méthode 1: Variable d'environnement individuelle
    env:
    - name: APP_NAME
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: app.name
    
    # Méthode 2: Importer toutes les clés
    envFrom:
    - configMapRef:
        name: app-config
    
    # Méthode 3: Monter comme fichiers
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
      readOnly: true
  
  volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:                       # Sélectionner des clés spécifiques
      - key: nginx.conf
        path: nginx.conf
```

---

## 4. Secret

### À quoi ça sert ?
Le **Secret** stocke des données sensibles encodées en base64 (mots de passe, tokens, certificats).

### Exemple commenté

```yaml
apiVersion: v1
kind: Secret

# ============================================================
# METADATA
# ============================================================
metadata:
  name: app-secrets
  namespace: default

# ============================================================
# TYPE : Type de Secret
# ============================================================
# Types disponibles:
# - Opaque: données génériques (défaut)
# - kubernetes.io/dockerconfigjson: credentials Docker
# - kubernetes.io/basic-auth: username/password
# - kubernetes.io/tls: certificat TLS
# - kubernetes.io/ssh-auth: clé SSH
type: Opaque

# ============================================================
# DATA : Données encodées en base64
# Encoder: echo -n 'valeur' | base64
# Décoder: echo 'encoded' | base64 --decode
# ============================================================
data:
  # Mot de passe ("MonMotDePasse123!")
  database-password: TW9uTW90RGVQYXNzZTEyMyE=
  
  # Username ("admin")
  database-username: YWRtaW4=
  
  # Token API
  api-token: c2stMTIzNDU2Nzg5MGFiY2RlZg==

# ============================================================
# STRINGDATA : Données en clair (auto-encodées)
# ATTENTION: Ne jamais commiter de vrais secrets!
# ============================================================
stringData:
  # Kubernetes encode automatiquement en base64
  jwt-secret: "my-super-secret-key"
  
  # Configuration complète
  database-config: |
    host: mysql-service
    port: 3306
    username: dbuser
    password: DbPass123!
    ssl: true

# ============================================================
# Secret Docker Registry
# ============================================================
---
apiVersion: v1
kind: Secret
metadata:
  name: docker-registry-secret
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2luZGV4...

# ============================================================
# Secret TLS
# ============================================================
---
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0t...
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVkt...

# ============================================================
# UTILISATION dans un Pod
# ============================================================
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-secrets
spec:
  containers:
  - name: app
    image: myapp
    
    # Méthode 1: Variable d'environnement
    env:
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: database-password
    
    # Méthode 2: Importer toutes les clés
    envFrom:
    - secretRef:
        name: app-secrets
    
    # Méthode 3: Monter comme fichiers
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true              # TOUJOURS en lecture seule!
  
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secrets
      defaultMode: 0400           # Permissions restrictives
  
  # Secret Docker pour images privées
  imagePullSecrets:
  - name: docker-registry-secret
```

### Création de Secrets via CLI

```bash
# Depuis des valeurs littérales
kubectl create secret generic db-secret \
  --from-literal=username=dbuser \
  --from-literal=password='MyP@ssw0rd'

# Depuis des fichiers
kubectl create secret generic ssh-secret \
  --from-file=ssh-privatekey=~/.ssh/id_rsa

# Secret TLS
kubectl create secret tls tls-secret \
  --cert=tls.crt \
  --key=tls.key

# Secret Docker
kubectl create secret docker-registry docker-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=myuser \
  --docker-password=mypass
```

---

## 5. Service

### À quoi ça sert ?
Le **Service** expose les Pods sur le réseau avec une IP stable, DNS et load balancing.

### Exemple commenté

```yaml
apiVersion: v1
kind: Service

# ============================================================
# METADATA
# ============================================================
metadata:
  name: service-nginx              # Devient le DNS interne
  namespace: default
  labels:
    app: nginx

# ============================================================
# SPEC : Spécification du Service
# ============================================================
spec:
  # Type de Service
  # - ClusterIP: IP interne uniquement (défaut)
  # - NodePort: Expose sur un port de chaque nœud
  # - LoadBalancer: Crée un load balancer externe
  # - ExternalName: Alias DNS vers un service externe
  type: LoadBalancer
  
  # Sélecteur : Pods ciblés par le Service
  selector:
    app: nginx                     # Cible les Pods avec ce label
    version: v1
  
  # Ports exposés
  ports:
  - name: http                     # Nom du port (optionnel)
    protocol: TCP                  # TCP | UDP
    port: 80                       # Port du Service (ClusterIP)
    targetPort: 80                 # Port du conteneur
    nodePort: 30080                # Port sur les nœuds (NodePort/LoadBalancer)
  
  - name: https
    protocol: TCP
    port: 443
    targetPort: 443
    nodePort: 30443
  
  # IP du cluster (optionnel, auto-assignée si absent)
  clusterIP: 10.96.0.100          # Ou "None" pour Headless Service
  
  # IP externe (pour LoadBalancer)
  loadBalancerIP: 192.168.1.240   # IP souhaitée (si supporté)
  
  # IPs externes autorisées (whitelist)
  loadBalancerSourceRanges:
  - 10.0.0.0/8
  - 192.168.0.0/16
  
  # Politique de session
  sessionAffinity: ClientIP        # None | ClientIP (sticky sessions)
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800        # Durée de l'affinité (3h)

# ============================================================
# Exemples de types de Services
# ============================================================

# Service ClusterIP (accès interne uniquement)
---
apiVersion: v1
kind: Service
metadata:
  name: service-internal
spec:
  type: ClusterIP                  # Type par défaut
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080

# Service NodePort (expose sur tous les nœuds)
---
apiVersion: v1
kind: Service
metadata:
  name: service-nodeport
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080                # Port 30000-32767

# Service LoadBalancer (avec cloud provider ou MetalLB)
---
apiVersion: v1
kind: Service
metadata:
  name: service-loadbalancer
  annotations:
    metallb.universe.tf/loadBalancerIPs: "192.168.1.240"
spec:
  type: LoadBalancer
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80

# Service Headless (sans ClusterIP, pour StatefulSet)
---
apiVersion: v1
kind: Service
metadata:
  name: service-headless
spec:
  clusterIP: None                  # Pas de ClusterIP
  selector:
    app: database
  ports:
  - port: 3306
    targetPort: 3306

# Service ExternalName (alias DNS)
---
apiVersion: v1
kind: Service
metadata:
  name: service-external
spec:
  type: ExternalName
  externalName: api.example.com    # Redirige vers ce DNS
```

## Résumé des Ressources

| Ressource | Usage | Exemple |
|-----------|-------|---------|
| **Pod** | Plus petite unité, conteneur(s) | Application simple |
| **Deployment** | Gère les Pods, réplication, updates | Application web |
| **ConfigMap** | Configuration non sensible | Fichiers config, variables |
| **Secret** | Données sensibles | Mots de passe, tokens |
| **Service** | Exposition réseau des Pods | Accès à l'application |

## Commandes Utiles

```bash
# Appliquer un manifeste
kubectl apply -f fichier.yml

# Voir les ressources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get configmaps
kubectl get secrets

# Détails d'une ressource
kubectl describe pod mon-pod
kubectl describe service mon-service

# Logs
kubectl logs mon-pod
kubectl logs deployment/mon-deployment

# Supprimer
kubectl delete -f fichier.yml
kubectl delete pod mon-pod
```