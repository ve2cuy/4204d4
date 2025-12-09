# Les Services Kubernetes

## À quoi sert un Service Kubernetes ?

Un **Service** Kubernetes résout un problème fondamental : **comment accéder aux Pods de manière stable ?**

### Le problème sans Service

Les Pods dans Kubernetes sont **éphémères** :
- Ils peuvent être détruits et recréés à tout moment
- Leur adresse IP change à chaque redémarrage
- Il peut y avoir plusieurs réplicas du même Pod
- Comment savoir quelle IP utiliser ?

### La solution : le Service

Un Service fournit :
1. **Une IP stable** (ClusterIP) qui ne change jamais
2. **Un nom DNS** facile à mémoriser
3. **Un load balancer** qui distribue le trafic entre les Pods
4. **Une abstraction** pour accéder aux Pods sans connaître leurs IPs

### Analogie

Imaginez un restaurant avec plusieurs cuisiniers (Pods) :
- Les cuisiniers peuvent changer de poste, partir, arriver
- Le **Service** est comme le numéro de téléphone du restaurant
- Les clients appellent toujours le même numéro
- Le standard (load balancer) dirige vers un cuisinier disponible

---

## Les 4 Types de Services

| Type | Accès | Usage typique |
|------|-------|---------------|
| **ClusterIP** | Interne uniquement | Communication entre services dans le cluster |
| **NodePort** | Externe via IP:Port des nœuds | Dev/test, accès direct |
| **LoadBalancer** | Externe via IP dédiée | Production, apps publiques |
| **ExternalName** | Alias DNS | Redirection vers service externe |

---

## 1. ClusterIP (Type par défaut)

### À quoi ça sert ?

- **Accès interne uniquement** (dans le cluster)
- IP virtuelle stable dans le réseau Kubernetes
- Le type **le plus courant** pour les services internes
- Utilisé pour la communication entre microservices

### Schéma

```
┌─────────────────────────────────────┐
│         Cluster Kubernetes          │
│                                     │
│  ┌──────┐    Service (ClusterIP)    │
│  │ Pod1 │◄───┐  10.96.0.100:80      │
│  └──────┘    │                      │
│              ├─► Load Balancer      │
│  ┌──────┐    │                      │
│  │ Pod2 │◄───┘                      │
│  └──────┘                           │
│                                     │
│  Accessible uniquement depuis       │
│  l'intérieur du cluster             │
└─────────────────────────────────────┘
```

### Exemple : Backend API

```yaml
# Deployment du backend
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: api
        image: myapi:1.0
        ports:
        - containerPort: 8080

---
# Service ClusterIP pour le backend
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP              # Type par défaut
  selector:
    app: backend               # Cible les Pods avec ce label
  ports:
  - name: http
    protocol: TCP
    port: 80                   # Port du Service
    targetPort: 8080           # Port du conteneur

# Accès depuis un autre Pod :
# curl http://backend-service.default.svc.cluster.local
# ou simplement : curl http://backend-service
```

### DNS automatique

Le Service crée automatiquement un enregistrement DNS :
- Format complet : `<service>.<namespace>.svc.cluster.local`
- Dans le même namespace : `<service>`
- Exemple : `backend-service` ou `backend-service.default.svc.cluster.local`

---

## 2. NodePort

### À quoi ça sert ?

- **Expose le Service sur un port de chaque nœud** du cluster
- Accessible depuis l'extérieur via `<NodeIP>:<NodePort>`
- Utile pour **développement et tests**
- Plage de ports : 30000-32767

### Schéma

```
┌─────────────────────────────────────┐
│         Cluster Kubernetes          │
│                                     │
│  Node1: 192.168.1.10:30080          │
│     ▼                               │
│  Service (NodePort)                 │
│     ▼                               │
│  ┌──────┐    ┌──────┐               │
│  │ Pod1 │    │ Pod2 │               │
│  └──────┘    └──────┘               │
│                                     │
└─────────────────────────────────────┘
         ▲
         │
    Internet / Réseau externe
    http://192.168.1.10:30080
```

### Exemple : Application de test

```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: webapp
  template:
    metadata:
      labels:
        app: webapp
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80

---
# Service NodePort
apiVersion: v1
kind: Service
metadata:
  name: webapp-nodeport
spec:
  type: NodePort
  selector:
    app: webapp
  ports:
  - name: http
    protocol: TCP
    port: 80                   # Port du Service (ClusterIP)
    targetPort: 80             # Port du conteneur
    nodePort: 30080            # Port sur chaque nœud (optionnel)
    # Si omis, Kubernetes assigne automatiquement un port 30000-32767

# Accès externe :
# http://<IP-du-noeud>:30080
# Exemples :
# http://192.168.1.10:30080
# http://192.168.1.11:30080  (si plusieurs nœuds)
```

### Avec Minikube

```bash
# Créer le service
kubectl apply -f webapp-nodeport.yml

# Obtenir l'URL d'accès
minikube service webapp-nodeport --url

# Ou ouvrir directement dans le navigateur
minikube service webapp-nodeport
```

---

## 3. LoadBalancer

### À quoi ça sert ?

- **Crée un load balancer externe** (cloud ou MetalLB)
- Assigne une **IP externe dédiée**
- Le type **recommandé pour la production**
- Nécessite un fournisseur de load balancer (AWS, GCP, Azure, MetalLB)

### Schéma

```
┌──────────────────────────────────────┐
│           Internet                   │
└───────────────┬──────────────────────┘
                │
         LoadBalancer IP
         192.168.1.240:80
                │
┌───────────────▼──────────────────────┐
│         Cluster Kubernetes           │
│                                      │
│  Service (LoadBalancer)              │
│         ▼                            │
│  ┌──────────┐  ┌──────────┐          │
│  │  Pod1    │  │  Pod2    │          │
│  │  :80     │  │  :80     │          │
│  └──────────┘  └──────────┘          │
└──────────────────────────────────────┘
```

### Exemple : Application web en production

```yaml
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webapp-prod
  namespace: production
spec:
  replicas: 5
  selector:
    matchLabels:
      app: webapp
      env: production
  template:
    metadata:
      labels:
        app: webapp
        env: production
    spec:
      containers:
      - name: app
        image: myapp:v2.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "200m"

---
# Service LoadBalancer
apiVersion: v1
kind: Service
metadata:
  name: webapp-loadbalancer
  namespace: production
  annotations:
    # Pour MetalLB : assigner une IP spécifique
    metallb.universe.tf/loadBalancerIPs: "192.168.1.240"
    # Pour AWS : type de load balancer
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: webapp
    env: production
  ports:
  - name: http
    protocol: TCP
    port: 80                   # Port externe
    targetPort: 8080           # Port du conteneur
  - name: https
    protocol: TCP
    port: 443
    targetPort: 8443
  
  # Optionnel : restreindre les IPs sources
  loadBalancerSourceRanges:
  - 10.0.0.0/8               # Réseau interne
  - 203.0.113.0/24           # IP publique spécifique

# Accès externe :
# http://192.168.1.240
# Le DNS peut pointer vers cette IP :
# monapp.com -> 192.168.1.240
```

### Vérifier l'IP externe

```bash
# Appliquer le manifeste
kubectl apply -f webapp-loadbalancer.yml

# Vérifier l'IP assignée
kubectl get svc webapp-loadbalancer

# Sortie :
# NAME                  TYPE           EXTERNAL-IP      PORT(S)
# webapp-loadbalancer   LoadBalancer   192.168.1.240    80:31234/TCP

# Tester
curl http://192.168.1.240
```

---

## 4. ExternalName

### À quoi ça sert ?

- **Crée un alias DNS** vers un service externe
- Pas de proxy, juste une redirection DNS
- Utile pour **migrer progressivement** vers Kubernetes
- Permet de référencer des services externes comme s'ils étaient internes

### Schéma

```
┌─────────────────────────────────────┐
│         Cluster Kubernetes          │
│                                     │
│  Pod demande:                       │
│  "database-service"                 │
│         │                           │
│         ▼                           │
│  Service ExternalName               │
│  Redirige vers:                     │
│  "db.external.com"                  │
│                                     │
└─────────────┬───────────────────────┘
              │
              ▼
    ┌─────────────────────┐
    │  Service externe    │
    │  db.external.com    │
    └─────────────────────┘
```

### Exemple 1 : Base de données externe

```yaml
# Service pointant vers une BD externe
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: default
spec:
  type: ExternalName
  externalName: mysql.external-provider.com  # DNS externe
  ports:
  - port: 3306

# Les Pods peuvent maintenant utiliser :
# mysql -h database-service -P 3306
# au lieu de :
# mysql -h mysql.external-provider.com -P 3306
```

### Exemple 2 : API externe

```yaml
# Service pour une API externe
apiVersion: v1
kind: Service
metadata:
  name: payment-api
spec:
  type: ExternalName
  externalName: api.stripe.com
  ports:
  - port: 443

# Utilisation dans l'application :
# https://payment-api/v1/charges
# au lieu de :
# https://api.stripe.com/v1/charges
```

### Exemple 3 : Migration progressive

```yaml
# Phase 1 : Service pointe vers l'ancien système
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  type: ExternalName
  externalName: legacy-users.company.com

---
# Phase 2 : Nouveau service Kubernetes déployé
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service-new
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: api
        image: user-service:v2.0
        ports:
        - containerPort: 8080

---
# Phase 3 : Changer le Service pour pointer vers les nouveaux Pods
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  type: ClusterIP              # Changé de ExternalName à ClusterIP
  selector:
    app: user-service          # Pointe vers les nouveaux Pods
  ports:
  - port: 80
    targetPort: 8080

# Les applications continuent d'utiliser "user-service" sans changement!
```

---

## Exemple Complet : Application Multi-tiers

Application avec frontend, backend, et base de données :

```yaml
# Base de données (ClusterIP - interne)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: db
  template:
    metadata:
      labels:
        app: db
    spec:
      containers:
      - name: postgres
        image: postgres:14
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_PASSWORD
          value: "secret"

---
apiVersion: v1
kind: Service
metadata:
  name: database-service
spec:
  type: ClusterIP              # Interne uniquement
  selector:
    app: db
  ports:
  - port: 5432
    targetPort: 5432

# Backend API (ClusterIP - interne)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      containers:
      - name: api
        image: myapi:1.0
        ports:
        - containerPort: 8080
        env:
        - name: DB_HOST
          value: "database-service"  # Utilise le nom du Service

---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP              # Interne uniquement
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080

# Frontend Web (LoadBalancer - public)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: myfrontend:1.0
        ports:
        - containerPort: 80
        env:
        - name: API_URL
          value: "http://backend-service"  # Utilise le nom du Service

---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: LoadBalancer           # Accessible publiquement
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80

# Architecture :
# Internet → LoadBalancer (frontend) → ClusterIP (backend) → ClusterIP (database)
```

---

## Comparaison des Types

| Critère | ClusterIP | NodePort | LoadBalancer | ExternalName |
|---------|-----------|----------|--------------|--------------|
| **Accès externe** | ❌ Non | ✅ Oui | ✅ Oui | ✅ Oui |
| **IP dédiée** | ❌ Non | ❌ Non | ✅ Oui | ❌ Non |
| **Load balancing** | ✅ Oui | ✅ Oui | ✅ Oui | ❌ Non |
| **Production** | ✅ Oui | ❌ Non | ✅ Oui | ✅ Oui |
| **Coût cloud** | Gratuit | Gratuit | 💰 Payant | Gratuit |
| **Usage typique** | Services internes | Dev/Test | Apps publiques | Services externes |

---

## Commandes Utiles

```bash
# Créer un Service
kubectl apply -f service.yml

# Lister les Services
kubectl get services
kubectl get svc

# Détails d'un Service
kubectl describe service mon-service

# Voir les endpoints (Pods ciblés)
kubectl get endpoints mon-service

# Tester un Service depuis un Pod
kubectl run test --rm -it --image=busybox -- sh
wget -O- http://mon-service

# Pour NodePort : obtenir l'URL (Minikube)
minikube service mon-service --url

# Pour LoadBalancer : obtenir l'IP externe
kubectl get svc mon-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Supprimer un Service
kubectl delete service mon-service
```

---

## Résumé

**Service = Point d'accès stable pour des Pods éphémères**

- **ClusterIP** : Communication interne entre microservices
- **NodePort** : Accès externe simple (dev/test)
- **LoadBalancer** : Production avec IP externe dédiée
- **ExternalName** : Alias vers services externes

**Règle d'or** : Toujours utiliser des Services, jamais les IPs des Pods directement !