# Installation et Configuration de MetalLB comme Load Balancer

## Qu'est-ce que MetalLB ?

MetalLB est un load balancer pour Kubernetes qui fonctionne sur des clusters bare-metal (sans fournisseur cloud). Il permet d'obtenir des IP externes pour les services de type `LoadBalancer`.

## Prérequis

- Kubernetes 1.13.0+
- Un pool d'adresses IP disponibles sur votre réseau
- Pas d'autre load balancer déjà installé (klipper-lb, cloud provider LB, etc.)

## Étape 1 : Vérifier la compatibilité

```bash
# Vérifier si kube-proxy est en mode IPVS ou iptables
kubectl get configmap kube-proxy -n kube-system -o yaml | grep mode

# Vérifier qu'aucun autre load balancer n'est installé
kubectl get pods -n kube-system
```

## Étape 2 : Installation de MetalLB

### Option A : Installation par manifeste (Recommandé)

```bash
# Installer MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml

# Vérifier l'installation
kubectl get pods -n metallb-system

# Attendre que les pods soient en Running
kubectl wait --namespace metallb-system \
                --for=condition=ready pod \
                --selector=app=metallb \
                --timeout=90s
```

### Option B : Installation avec Helm

```bash
# Ajouter le repo Helm
helm repo add metallb https://metallb.github.io/metallb
helm repo update

# Installer MetalLB
helm install metallb metallb/metallb --namespace metallb-system --create-namespace

# Vérifier l'installation
kubectl get pods -n metallb-system
```

## Étape 3 : Configuration de MetalLB

### Pour Minikube

```bash
# Obtenir la plage d'IP disponible
minikube ip
# Exemple: 192.168.49.2

# Si votre Minikube est sur 192.168.49.2
# Utilisez une plage comme 192.168.49.100-192.168.49.110
```

**Fichier : `metallb-config-minikube.yml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.49.100-192.168.49.110
```

### Configuration Layer 2 (Mode standard)

**Fichier : `metallb-ipaddresspool.yml`**

```yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  # Adapter cette plage selon votre réseau
  - 192.168.1.240-192.168.1.250
  # Ou utiliser la notation CIDR
  # - 192.168.1.240/28

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
```

### Configuration pour réseau local typique

**Si votre machine est sur 192.168.0.x :**

```yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: local-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.0.200-192.168.0.210

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: local-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - local-pool
```

**Si votre machine est sur 10.0.0.x :**

```yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: home-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.0.0.200-10.0.0.210

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: home-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - home-pool
```

### Appliquer la configuration

```bash
kubectl apply -f metallb-ipaddresspool.yml

# Vérifier la configuration
kubectl get ipaddresspool -n metallb-system
kubectl get l2advertisement -n metallb-system
```

## Étape 4 : Tester MetalLB

### Exemple 1 : Service simple

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: LoadBalancer  # MetalLB va assigner une IP externe
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

```bash
# Appliquer le test
kubectl apply -f nginx-test.yml

# Vérifier l'IP externe assignée
kubectl get svc nginx-service

# Devrait afficher quelque chose comme:
# NAME            TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
# nginx-service   LoadBalancer   10.96.123.45    192.168.1.240    80:30123/TCP   1m

# Tester l'accès
curl http://192.168.1.240
```

### Exemple 2 : Traefik avec MetalLB

```yaml
apiVersion: v1
kind: Service
metadata:
  name: traefik-service
  namespace: traefik
spec:
  type: LoadBalancer  # MetalLB assignera une IP
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
```

```bash
# Appliquer
kubectl apply -f traefik-service.yml

# Vérifier l'IP assignée
kubectl get svc -n traefik traefik-service

# Maintenant Traefik est accessible via l'IP externe
# Exemple: http://192.168.1.240
```

## Étape 5 : Configuration avancée

### Assigner une IP spécifique à un service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mon-service
  annotations:
    metallb.universe.tf/loadBalancerIPs: 192.168.1.240
spec:
  type: LoadBalancer
  selector:
    app: mon-app
  ports:
    - port: 80
      targetPort: 80
```

### Créer plusieurs pools d'adresses

```yaml
---
# Pool pour les services web
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: web-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.245

---
# Pool pour les services API
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: api-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.246-192.168.1.250

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: web-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - web-pool

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: api-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - api-pool
```

**Utiliser un pool spécifique :**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
  annotations:
    metallb.universe.tf/address-pool: web-pool
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
```

### Configuration BGP (Mode avancé)

Si vous avez un routeur BGP sur votre réseau :

```yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: bgp-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250

---
apiVersion: metallb.io/v1beta1
kind: BGPPeer
metadata:
  name: router
  namespace: metallb-system
spec:
  myASN: 64500
  peerASN: 64501
  peerAddress: 192.168.1.1

---
apiVersion: metallb.io/v1beta1
kind: BGPAdvertisement
metadata:
  name: bgp-adv
  namespace: metallb-system
spec:
  ipAddressPools:
  - bgp-pool
```

## Exemple complet : Déploiement avec MetalLB

```yaml
---
# Deployment
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
# Service avec LoadBalancer (MetalLB)
apiVersion: v1
kind: Service
metadata:
  name: service-superminou
spec:
  type: LoadBalancer
  selector:
    app: superminou
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

---
# Ingress (optionnel, si vous utilisez aussi Traefik)
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
                name: service-superminou
                port:
                  number: 80
```

## Intégration MetalLB + Traefik

### Scénario complet

```yaml
---
# 1. Pool d'adresses MetalLB
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: main-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.1.240-192.168.1.250

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: main-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - main-pool

---
# 2. Service Traefik avec LoadBalancer
apiVersion: v1
kind: Service
metadata:
  name: traefik-lb
  namespace: traefik
  annotations:
    metallb.universe.tf/loadBalancerIPs: 192.168.1.240
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

---
# 3. Déploiement de votre application
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
        image: nginx
        ports:
        - containerPort: 80

---
# 4. Service ClusterIP (pas LoadBalancer, Traefik s'en charge)
apiVersion: v1
kind: Service
metadata:
  name: service-app
spec:
  type: ClusterIP
  selector:
    app: mon-app
  ports:
    - port: 80
      targetPort: 80

---
# 5. Ingress via Traefik
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-app
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
    - host: app.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: service-app
                port:
                  number: 80
```

**Configuration DNS :**

```bash
# Ajouter dans /etc/hosts
192.168.1.240 app.local
192.168.1.240 autre-app.local

# Tester
curl http://app.local
```

## Troubleshooting

### Vérifier l'état de MetalLB

```bash
# Vérifier les pods
kubectl get pods -n metallb-system

# Vérifier les logs du controller
kubectl logs -n metallb-system -l component=controller

# Vérifier les logs du speaker
kubectl logs -n metallb-system -l component=speaker

# Vérifier la configuration
kubectl get ipaddresspool -n metallb-system
kubectl describe ipaddresspool -n metallb-system
```

### Pas d'IP externe assignée

```bash
# Vérifier que MetalLB est bien installé
kubectl get pods -n metallb-system

# Vérifier qu'il y a des IPs disponibles dans le pool
kubectl get ipaddresspool -n metallb-system -o yaml

# Vérifier les événements du service
kubectl describe svc <nom-service>
```

### Conflit avec klipper-lb (K3s)

```bash
# Désactiver klipper-lb sur K3s
# Éditer /etc/systemd/system/k3s.service
# Ajouter --disable=servicelb

# Ou lors de l'installation
curl -sfL https://get.k3s.io | sh -s - --disable=servicelb
```

### IP non accessible depuis l'extérieur

```bash
# Vérifier le mode de MetalLB (doit être Layer 2 pour réseau local)
kubectl get l2advertisement -n metallb-system

# Vérifier que l'IP est dans la même plage que votre réseau
ip addr show

# Tester depuis le cluster
kubectl run test --rm -it --image=busybox -- wget -O- http://<IP-EXTERNE>
```

## Commandes utiles

```bash
# Lister tous les services LoadBalancer
kubectl get svc --all-namespaces -o wide | grep LoadBalancer

# Voir les IPs assignées
kubectl get svc -A -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.name}{"\t"}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}'

# Supprimer MetalLB
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.3/config/manifests/metallb-native.yaml

# Redémarrer MetalLB
kubectl rollout restart deployment controller -n metallb-system
kubectl rollout restart daemonset speaker -n metallb-system
```

## Configuration recommandée pour un lab local

```yaml
---
# Configuration simple pour un environnement de test
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: lab-pool
  namespace: metallb-system
spec:
  addresses:
  # Adapter selon votre réseau local
  # Pour 192.168.1.x
  - 192.168.1.200-192.168.1.220
  # Pour 192.168.0.x
  # - 192.168.0.200-192.168.0.220
  # Pour 10.0.0.x
  # - 10.0.0.200-10.0.0.220

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: lab-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - lab-pool
```

## Ressources

- [Documentation MetalLB](https://metallb.universe.tf/)
- [Configuration Layer 2](https://metallb.universe.tf/configuration/_advanced_l2_configuration/)
- [Configuration BGP](https://metallb.universe.tf/configuration/_advanced_bgp_configuration/)
- [Troubleshooting](https://metallb.universe.tf/troubleshooting/)