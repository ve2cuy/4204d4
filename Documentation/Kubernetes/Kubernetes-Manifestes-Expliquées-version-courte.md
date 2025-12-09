# Guide des Manifestes Kubernetes (Version courte)

## Structure de base

Tous les manifestes Kubernetes partagent cette structure :

```yaml
apiVersion: # Version de l'API Kubernetes
kind:       # Type de ressource (Pod, Deployment, etc.)
metadata:   # Nom, labels, namespace
spec:       # Spécification (état désiré)
```

---

## 1. Pod

**À quoi ça sert ?** Plus petite unité déployable. Groupe de conteneur(s) partageant réseau et stockage.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mon-pod              # Nom du Pod
  labels:
    app: nginx               # Labels pour sélection
spec:
  containers:
  - name: nginx              # Nom du conteneur
    image: nginx:1.21        # Image Docker
    ports:
    - containerPort: 80      # Port exposé
    env:                     # Variables d'environnement
    - name: ENVIRONMENT
      value: "production"
    resources:               # Limites CPU/Mémoire
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

---

## 2. Deployment

**À quoi ça sert ?** Gère les Pods : réplication, mises à jour, rollback, auto-guérison.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-nginx         # Nom du Deployment
  labels:
    app: nginx
spec:
  replicas: 3                # Nombre de Pods
  selector:
    matchLabels:
      app: nginx             # Sélectionne les Pods avec ce label
  template:                  # Template des Pods créés
    metadata:
      labels:
        app: nginx           # Labels des Pods
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
        env:
        - name: DB_PASSWORD  # Variable depuis un Secret
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: password
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

---

## 3. ConfigMap

**À quoi ça sert ?** Stocke des données de configuration non sensibles (variables, fichiers).

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config           # Nom du ConfigMap
data:
  # Variables simples
  app.name: "SuperMinou"
  database.host: "mysql-service"
  database.port: "3306"
  
  # Fichier de configuration complet
  nginx.conf: |
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html;
        }
    }
```

**Utilisation dans un Pod :**

```yaml
spec:
  containers:
  - name: app
    image: myapp
    env:
    - name: APP_NAME         # Variable individuelle
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: app.name
    envFrom:                 # Toutes les variables
    - configMapRef:
        name: app-config
    volumeMounts:            # Monter comme fichiers
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: app-config
```

---

## 4. Secret

**À quoi ça sert ?** Stocke des données sensibles encodées en base64 (mots de passe, tokens).

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets          # Nom du Secret
type: Opaque
data:
  # Données encodées en base64
  # echo -n 'MonMotDePasse' | base64
  database-password: TW9uTW90RGVQYXNzZQ==
  api-token: c2stMTIzNDU2Nzg5MA==

# OU avec stringData (encodage automatique)
stringData:
  jwt-secret: "my-secret-key"    # Kubernetes encode automatiquement
```

**Utilisation dans un Pod :**

```yaml
spec:
  containers:
  - name: app
    image: myapp
    env:
    - name: DB_PASSWORD      # Variable individuelle
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: database-password
    envFrom:                 # Toutes les variables
    - secretRef:
        name: app-secrets
    volumeMounts:            # Monter comme fichiers
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true         # TOUJOURS en lecture seule
  volumes:
  - name: secret-volume
    secret:
      secretName: app-secrets
```

**Créer un Secret via CLI :**

```bash
# Depuis des valeurs
kubectl create secret generic db-secret \
  --from-literal=username=admin \
  --from-literal=password='MonP@ss'

# Depuis des fichiers
kubectl create secret generic ssh-secret \
  --from-file=ssh-privatekey=~/.ssh/id_rsa
```

---

## 5. Service

**À quoi ça sert ?** Expose les Pods sur le réseau avec IP stable, DNS et load balancing.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: service-nginx        # Nom (devient le DNS interne)
spec:
  type: LoadBalancer         # ClusterIP | NodePort | LoadBalancer
  selector:
    app: nginx               # Cible les Pods avec ce label
  ports:
  - name: http
    port: 80                 # Port du Service
    targetPort: 80           # Port du conteneur
    nodePort: 30080          # Port sur les nœuds (optionnel)
```

**Types de Services :**

```yaml
# ClusterIP (accès interne uniquement) - TYPE PAR DÉFAUT
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80

# NodePort (expose sur tous les nœuds)
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080          # Port 30000-32767

# LoadBalancer (IP externe avec MetalLB ou cloud)
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

---

## Exemple Complet

Application avec toutes les ressources :

```yaml
# ConfigMap
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  database.host: "mysql-service"

# Secret
---
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
stringData:
  database.password: "MonP@ssw0rd"

# Deployment
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mon-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: mon-app
  template:
    metadata:
      labels:
        app: mon-app
    spec:
      containers:
      - name: app
        image: myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database.host
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database.password

# Service
---
apiVersion: v1
kind: Service
metadata:
  name: service-app
spec:
  type: LoadBalancer
  selector:
    app: mon-app
  ports:
  - port: 80
    targetPort: 8080
```

---

## Commandes Essentielles

```bash
# Appliquer un manifeste
kubectl apply -f fichier.yml

# Voir les ressources
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get configmaps
kubectl get secrets

# Détails
kubectl describe pod mon-pod
kubectl describe service mon-service

# Logs
kubectl logs mon-pod
kubectl logs deployment/mon-deployment -f

# Supprimer
kubectl delete -f fichier.yml
kubectl delete pod mon-pod
```

---

## Résumé

| Ressource | Usage | Type de données |
|-----------|-------|-----------------|
| **Pod** | Unité de base (conteneur) | - |
| **Deployment** | Gestion des Pods | - |
| **ConfigMap** | Configuration | Non sensibles |
| **Secret** | Credentials | Sensibles (base64) |
| **Service** | Exposition réseau | - |