# Auto Scaling sous Kubernetes

## Table des matières

1. [Introduction](#introduction)
2. [Horizontal Pod Autoscaler (HPA)](#horizontal-pod-autoscaler-hpa)
3. [Vertical Pod Autoscaler (VPA)](#vertical-pod-autoscaler-vpa)
4. [Cluster Autoscaler](#cluster-autoscaler)
5. [KEDA – Event-Driven Autoscaling](#keda--event-driven-autoscaling)
6. [Bonnes pratiques](#bonnes-pratiques)

---

## Introduction

L'auto scaling dans Kubernetes désigne la capacité du cluster à ajuster **automatiquement** le nombre de pods ou les ressources allouées en fonction de la charge courante. Il existe trois mécanismes principaux, complémentaires :

| Mécanisme | Agit sur | Métrique type |
|-----------|----------|---------------|
| **HPA** – Horizontal Pod Autoscaler | Nombre de pods | CPU, mémoire, métriques custom |
| **VPA** – Vertical Pod Autoscaler | Ressources d'un pod (CPU/RAM) | Utilisation historique |
| **Cluster Autoscaler** | Nombre de nœuds | Pods en état `Pending` |

> **Prérequis** : `kubectl` configuré, `metrics-server` installé (requis pour HPA/VPA).

### Vérifier que metrics-server est actif

```bash
kubectl top nodes
kubectl top pods -A
```

Si la commande échoue, installez `metrics-server` :

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## Horizontal Pod Autoscaler (HPA)

Le HPA surveille les métriques d'un `Deployment` (ou `StatefulSet`, `ReplicaSet`) et ajuste le nombre de réplicas à la hausse ou à la baisse.

### Principe de fonctionnement

```
Charge augmente → métriques dépassent le seuil → HPA crée de nouveaux pods
Charge diminue → métriques sous le seuil → HPA supprime des pods (avec stabilisation)
```

### Exemple pratique — Scaling sur CPU

#### 1. Déployer une application de test

```bash
kubectl create deployment php-apache \
  --image=registry.k8s.io/hpa-example \
  --port=80

kubectl expose deployment php-apache --port=80
```

#### 2. Définir les requests de ressources (obligatoire pour HPA)

```bash
kubectl set resources deployment php-apache \
  --requests=cpu=200m,memory=128Mi \
  --limits=cpu=500m,memory=256Mi
```

#### 3. Créer le HPA

```bash
# Via kubectl autoscale (méthode rapide)
kubectl autoscale deployment php-apache \
  --cpu-percent=50 \
  --min=1 \
  --max=10
```

Ou via un manifeste YAML :

```yaml
# hpa-cpu.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

```bash
kubectl apply -f hpa-cpu.yaml
```

#### 4. Observer le HPA

```bash
kubectl get hpa php-apache --watch
# AFFICHE : NAME        REFERENCE                     TARGETS   MINPODS   MAXPODS   REPLICAS
# php-apache  Deployment/php-apache         0%/50%    1         10        1
```

#### 5. Générer de la charge (dans un second terminal)

```bash
kubectl run load-generator \
  --image=busybox:1.28 \
  --restart=Never \
  -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

Observez le scaling :

```bash
kubectl get hpa php-apache --watch
# Les REPLICAS vont augmenter progressivement
```

#### 6. Arrêter la charge et observer le scale-down

```bash
kubectl delete pod load-generator

# Le scale-down a un délai de stabilisation par défaut de 5 minutes
kubectl get hpa php-apache --watch
```

#### 7. Nettoyer

```bash
kubectl delete deployment php-apache
kubectl delete service php-apache
kubectl delete hpa php-apache
```

---

### HPA sur métriques mémoire

```yaml
# hpa-memory.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-memory
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 8
  metrics:
    - type: Resource
      resource:
        name: memory
        target:
          type: AverageValue
          averageValue: 200Mi
```

---

### Comportement de scaling (scaleDown/scaleUp)

Il est possible de contrôler la vitesse de scaling pour éviter les oscillations :

```yaml
spec:
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300   # Attente avant de réduire
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60             # Supprimer max 10% par minute
    scaleUp:
      stabilizationWindowSeconds: 0     # Scale-up immédiat
      policies:
        - type: Pods
          value: 4
          periodSeconds: 15             # Ajouter max 4 pods toutes les 15s
```

---

## Vertical Pod Autoscaler (VPA)

Le VPA ajuste les **requêtes de ressources** (CPU/RAM) d'un pod existant, sans changer le nombre de réplicas. Il est particulièrement utile pour les charges de travail imprévisibles ou mal calibrées.

> ⚠️ Le VPA nécessite une installation séparée.

### Installation du VPA

```bash
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler
./hack/vpa-install.sh
```

Vérification :

```bash
kubectl get pods -n kube-system | grep vpa
```

### Modes de fonctionnement

| Mode | Comportement |
|------|--------------|
| `Off` | Recommandations uniquement (pas d'application) |
| `Initial` | Applique les recommendations seulement à la création du pod |
| `Auto` | Recrée les pods avec les nouvelles ressources (redémarrage) |
| `Recreate` | Identique à `Auto` mais force la recréation |

### Exemple pratique

#### 1. Déployer une application

```bash
kubectl create deployment vpa-demo \
  --image=nginx:alpine \
  --replicas=2
```

#### 2. Créer un objet VPA en mode recommandation

```yaml
# vpa-demo.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-demo
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: vpa-demo
  updatePolicy:
    updateMode: "Off"   # Recommandations uniquement
  resourcePolicy:
    containerPolicies:
      - containerName: nginx
        minAllowed:
          cpu: 50m
          memory: 64Mi
        maxAllowed:
          cpu: 1
          memory: 512Mi
```

```bash
kubectl apply -f vpa-demo.yaml
```

#### 3. Consulter les recommandations

```bash
kubectl describe vpa vpa-demo
# Chercher la section "Recommendation"
```

Ou en JSON pour parser les valeurs :

```bash
kubectl get vpa vpa-demo -o json | \
  jq '.status.recommendation.containerRecommendations'
```

#### 4. Nettoyer

```bash
kubectl delete deployment vpa-demo
kubectl delete vpa vpa-demo
```

---

## Cluster Autoscaler

Le Cluster Autoscaler agit au niveau de l'infrastructure : il ajoute ou supprime des **nœuds** du cluster selon que des pods sont en attente (`Pending`) ou que des nœuds sont sous-utilisés.

> ⚠️ Le Cluster Autoscaler est spécifique à chaque provider cloud (GKE, EKS, AKS…). Les exemples ci-dessous sont génériques.

### Principe

```
Pod Pending (plus de ressources dispo) → Cluster Autoscaler ajoute un nœud
Nœud sous-utilisé depuis > 10 min    → Cluster Autoscaler supprime le nœud
```

### Simuler un manque de ressources (sans cloud provider)

Vous pouvez tester le comportement sur un cluster local en créant intentionnellement une pression sur les ressources :

```bash
# Voir les ressources disponibles sur les nœuds
kubectl describe nodes | grep -A5 "Allocated resources"

# Créer un déploiement qui demande beaucoup de CPU
kubectl create deployment resource-hog \
  --image=nginx:alpine \
  --replicas=10

kubectl set resources deployment resource-hog \
  --requests=cpu=500m,memory=256Mi

# Observer les pods en état Pending
kubectl get pods --watch | grep Pending
```

### Annotations utiles pour le Cluster Autoscaler

```yaml
# Empêcher l'éviction d'un pod critique
metadata:
  annotations:
    cluster-autoscaler.kubernetes.io/safe-to-evict: "false"
```

```bash
# Voir les événements du Cluster Autoscaler
kubectl get events --field-selector reason=TriggeredScaleUp
kubectl get events --field-selector reason=ScaleDown
```

---

## KEDA – Event-Driven Autoscaling

KEDA (Kubernetes Event-Driven Autoscaling) étend le HPA pour scaler sur des **sources externes** : files de messages (Kafka, RabbitMQ, SQS), bases de données, métriques Prometheus, etc.

### Installation de KEDA

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda --namespace keda --create-namespace
```

Vérification :

```bash
kubectl get pods -n keda
```

### Exemple : Scaling sur une file RabbitMQ

```yaml
# keda-rabbitmq.yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: rabbitmq-consumer
spec:
  scaleTargetRef:
    name: rabbitmq-consumer-deployment
  minReplicaCount: 0        # Scale-to-zero possible !
  maxReplicaCount: 20
  triggers:
    - type: rabbitmq
      metadata:
        queueName: my-queue
        host: amqp://guest:guest@rabbitmq:5672/
        queueLength: "5"    # 1 pod par 5 messages en attente
```

### Exemple : Scaling sur métriques Prometheus

```yaml
# keda-prometheus.yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prometheus-scaler
spec:
  scaleTargetRef:
    name: my-app
  minReplicaCount: 1
  maxReplicaCount: 15
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus-server.monitoring:9090
        metricName: http_requests_per_second
        threshold: "100"
        query: sum(rate(http_requests_total[2m]))
```

```bash
kubectl apply -f keda-prometheus.yaml

# Surveiller le ScaledObject
kubectl get scaledobject prometheus-scaler
kubectl describe scaledobject prometheus-scaler
```

---

## Bonnes pratiques

### 1. Toujours définir des `requests` et `limits`

Le HPA ne peut pas fonctionner sans `requests` CPU/mémoire définis sur les conteneurs.

```bash
# Vérifier que les ressources sont définies
kubectl get deployment my-app -o json | \
  jq '.spec.template.spec.containers[].resources'
```

### 2. Ne pas combiner HPA et VPA en mode `Auto`

HPA et VPA en mode automatique peuvent entrer en conflit. Préférez :
- HPA pour le scaling horizontal
- VPA en mode `Off` ou `Initial` pour les recommandations

### 3. Configurer les `PodDisruptionBudgets` (PDB)

Un PDB garantit qu'un minimum de pods reste disponible pendant un scale-down.

```yaml
# pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: my-app-pdb
spec:
  minAvailable: 2   # ou maxUnavailable: 1
  selector:
    matchLabels:
      app: my-app
```

```bash
kubectl apply -f pdb.yaml
kubectl get pdb
```

### 4. Surveiller les événements de scaling

```bash
# Événements HPA
kubectl describe hpa my-hpa

# Événements généraux liés au scaling
kubectl get events --sort-by=.metadata.creationTimestamp | grep -i scale

# Logs du controller HPA (dans kube-system)
kubectl logs -n kube-system \
  -l component=kube-controller-manager \
  --tail=50 | grep -i hpa
```

### 5. Utiliser `kubectl top` pour valider les métriques

```bash
# Ressources des pods en temps réel
kubectl top pods --sort-by=cpu

# Ressources des nœuds
kubectl top nodes
```

---

## Récapitulatif des commandes essentielles

```bash
# Créer un HPA rapidement
kubectl autoscale deployment <nom> --cpu-percent=50 --min=1 --max=10

# Voir l'état du HPA
kubectl get hpa
kubectl describe hpa <nom>

# Voir les recommandations VPA
kubectl describe vpa <nom>

# Forcer un scaling manuel (contourne temporairement le HPA)
kubectl scale deployment <nom> --replicas=5

# Voir tous les objets de scaling
kubectl get hpa,vpa,scaledobject -A
```

---

**Document rédigé par Alain Boudreault © 2021-2026**  
**Version 2026.02.26.1**