# Configuration Ingress avec Traefik pour Kubernetes

## Étape 1 : Installation de Traefik

### Option A : Installation avec Helm (Recommandé)

```bash
# Ajouter le repo Helm de Traefik
helm repo add traefik https://traefik.github.io/charts
helm repo update

# Installer Traefik dans le namespace kube-system
helm install traefik traefik/traefik -n kube-system

# Ou avec des valeurs personnalisées
helm install traefik traefik/traefik \
  --namespace kube-system \
  --set "ports.web.exposedPort=80" \
  --set "ports.websecure.exposedPort=443"
```

### Option B : Installation avec manifestes YAML

**Fichier : `traefik-deployment.yml`**

```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: traefik

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: traefik-account
  namespace: traefik

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: traefik-role
rules:
  - apiGroups:
      - ""
    resources:
      - services
      - endpoints
      - secrets
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io
    resources:
      - ingresses
      - ingressclasses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - extensions
      - networking.k8s.io
    resources:
      - ingresses/status
    verbs:
      - update

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: traefik-role-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: traefik-role
subjects:
  - kind: ServiceAccount
    name: traefik-account
    namespace: traefik

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traefik-deployment
  namespace: traefik
  labels:
    app: traefik
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traefik
  template:
    metadata:
      labels:
        app: traefik
    spec:
      serviceAccountName: traefik-account
      containers:
        - name: traefik
          image: traefik:v2.10
          args:
            - --api.insecure=true
            - --providers.kubernetesingress
            - --entrypoints.web.address=:80
            - --entrypoints.websecure.address=:443
          ports:
            - name: web
              containerPort: 80
            - name: websecure
              containerPort: 443
            - name: dashboard
              containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: traefik-service
  namespace: traefik
spec:
  type: LoadBalancer
  selector:
    app: traefik
  ports:
    - name: web
      port: 80
      targetPort: 80
    - name: websecure
      port: 443
      targetPort: 443
    - name: dashboard
      port: 8080
      targetPort: 8080

---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: traefik
spec:
  controller: traefik.io/ingress-controller
```

**Appliquer le manifeste :**

```bash
kubectl apply -f traefik-deployment.yml
```

### Option C : Pour Minikube

```bash
# Activer l'addon Ingress avec Traefik
minikube addons enable ingress

# Ou utiliser Traefik spécifiquement
kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.10/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml
```

## Étape 2 : Vérifier l'installation de Traefik

```bash
# Vérifier le déploiement
kubectl get pods -n traefik
kubectl get svc -n traefik

# Vérifier l'IngressClass
kubectl get ingressclass
```

## Étape 3 : Créer votre Ingress

### Exemple de base pour votre service-web

**Fichier : `ingress-web.yml`**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-web
  namespace: default
  annotations:
    # Spécifier Traefik comme contrôleur
    kubernetes.io/ingress.class: traefik
spec:
  rules:
    - host: monapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-web
                port:
                  number: 80
```

**Appliquer l'Ingress :**

```bash
kubectl apply -f ingress-web.yml
```

### Exemple avec plusieurs services

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-multi-services
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
    # Service web principal
    - host: monapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-web
                port:
                  number: 80
    
    # Service API
    - host: api.monapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-api
                port:
                  number: 8080
    
    # Service admin
    - host: admin.monapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-admin
                port:
                  number: 3000
```

### Exemple avec path routing (chemins)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-paths
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.middlewares: default-strip-prefix@kubernetescrd
spec:
  rules:
    - host: monapp.local
      http:
        paths:
          # Route vers le service web
          - path: /web
            pathType: Prefix
            backend:
              service:
                name: service-web
                port:
                  number: 80
          
          # Route vers l'API
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: service-api
                port:
                  number: 8080
          
          # Route vers le dashboard
          - path: /dashboard
            pathType: Prefix
            backend:
              service:
                name: service-dashboard
                port:
                  number: 3000
```

## Étape 4 : Configuration du DNS local

### Pour Minikube

```bash
# Obtenir l'IP de Minikube
minikube ip

# Exemple de sortie: 192.168.49.2

# Ajouter dans /etc/hosts (Linux/Mac) ou C:\Windows\System32\drivers\etc\hosts (Windows)
192.168.49.2 monapp.local
192.168.49.2 api.monapp.local
192.168.49.2 admin.monapp.local
```

### Pour un cluster standard

```bash
# Obtenir l'IP externe du service Traefik
kubectl get svc -n traefik traefik-service

# Ajouter dans /etc/hosts
<IP_EXTERNE> monapp.local
```

## Étape 5 : Tester l'Ingress

```bash
# Tester avec curl
curl http://monapp.local

# Ou avec un navigateur
# Ouvrir: http://monapp.local

# Vérifier le statut de l'Ingress
kubectl get ingress
kubectl describe ingress ingress-web
```

## Configuration avancée avec annotations Traefik

### Redirection HTTP vers HTTPS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-web-secure
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/redirect-entry-point: https
    traefik.ingress.kubernetes.io/redirect-permanent: "true"
spec:
  tls:
    - hosts:
        - monapp.local
      secretName: monapp-tls
  rules:
    - host: monapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-web
                port:
                  number: 80
```

### Middleware : Strip Prefix

```yaml
# Définition du Middleware
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: strip-prefix
  namespace: default
spec:
  stripPrefix:
    prefixes:
      - /api
      - /web

---
# Ingress utilisant le middleware
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-with-middleware
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.middlewares: default-strip-prefix@kubernetescrd
spec:
  rules:
    - host: monapp.local
      http:
        paths:
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: service-api
                port:
                  number: 8080
```

### Middleware : Authentification Basic

```yaml
# Créer le secret avec les credentials
# htpasswd -nb user password | base64
apiVersion: v1
kind: Secret
metadata:
  name: authsecret
  namespace: default
data:
  users: dXNlcjokYXByMSRINnVza2trVyRJZ1hMUDZ3Tm5oOGJ1UEQyZVIzZ3AuCg==

---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: basic-auth
  namespace: default
spec:
  basicAuth:
    secret: authsecret

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-protected
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.middlewares: default-basic-auth@kubernetescrd
spec:
  rules:
    - host: admin.monapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-admin
                port:
                  number: 80
```

### Rate Limiting

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: rate-limit
  namespace: default
spec:
  rateLimit:
    average: 100
    burst: 200

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-rate-limited
  namespace: default
  annotations:
    kubernetes.io/ingress.class: traefik
    traefik.ingress.kubernetes.io/router.middlewares: default-rate-limit@kubernetescrd
spec:
  rules:
    - host: api.monapp.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-api
                port:
                  number: 8080
```

## Accéder au Dashboard Traefik

```bash
# Port-forward pour accéder au dashboard
kubectl port-forward -n traefik $(kubectl get pods -n traefik --selector "app=traefik" --output=name) 9000:8080

# Ouvrir dans le navigateur
# http://localhost:9000/dashboard/
```

### Exposer le Dashboard via Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: traefik-dashboard
  namespace: traefik
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
    - host: traefik.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: traefik-service
                port:
                  number: 8080
```

## Exemple complet : SuperMinou avec Ingress

```yaml
---
# Deployment SuperMinou
apiVersion: apps/v1
kind: Deployment
metadata:
  name: deploy-superminou
  labels:
    app: superminou
spec:
  replicas: 3
  selector:
    matchLabels:
      app: superminou
  template:
    metadata:
      labels:
        app: superminou
    spec:
      containers:
      - name: superminou
        image: alainboudreault/superminou:latest
        ports:
        - containerPort: 80

---
# Service SuperMinou
apiVersion: v1
kind: Service
metadata:
  name: service-web
spec:
  selector:
    app: superminou
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
# Ingress SuperMinou
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-superminou
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
    - host: superminou.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-web
                port:
                  number: 80
```

**Déployer :**

```bash
kubectl apply -f superminou-complete.yml

# Ajouter dans /etc/hosts
echo "$(minikube ip) superminou.local" | sudo tee -a /etc/hosts

# Tester
curl http://superminou.local
```

## Troubleshooting

### Vérifier les logs Traefik

```bash
kubectl logs -n traefik -l app=traefik -f
```

### Vérifier l'état de l'Ingress

```bash
kubectl describe ingress ingress-web
kubectl get ingress -A
```

### Erreur 404

```bash
# Vérifier que le service existe et fonctionne
kubectl get svc service-web
kubectl get endpoints service-web

# Tester le service directement
kubectl port-forward svc/service-web 8080:80
curl http://localhost:8080
```

### Ingress non accessible

```bash
# Vérifier le service Traefik
kubectl get svc -n traefik

# Pour Minikube, utiliser le tunnel
minikube tunnel
```

## Commandes utiles

```bash
# Lister tous les Ingress
kubectl get ingress -A

# Voir les détails d'un Ingress
kubectl describe ingress <nom-ingress>

# Voir les logs Traefik
kubectl logs -n traefik deployment/traefik-deployment -f

# Redémarrer Traefik
kubectl rollout restart deployment/traefik-deployment -n traefik

# Supprimer un Ingress
kubectl delete ingress <nom-ingress>
```

## Ressources

- [Documentation Traefik](https://doc.traefik.io/traefik/)
- [Traefik & Kubernetes](https://doc.traefik.io/traefik/providers/kubernetes-ingress/)
- [Traefik Middlewares](https://doc.traefik.io/traefik/middlewares/overview/)