# Explication détaillée de la section `resources`

## Vue d'ensemble

La section `resources` définit les **ressources CPU et mémoire** allouées à un conteneur. Elle contient deux sous-sections : `requests` et `limits`.

---

## Structure complète

```yaml
resources:
  requests:      # Ressources garanties (minimum)
    cpu: 100m
    memory: 128Mi
  limits:        # Ressources maximales (plafond)
    cpu: 500m
    memory: 512Mi
```

---

## 1. `resources:`

Cette clé indique le début de la section qui définit les ressources du conteneur.

---

## 2. `requests:`

Les **requests** (demandes) définissent les **ressources minimales garanties** pour le conteneur.

### Rôle des requests :

- **Planification (Scheduling)** : Kubernetes utilise ces valeurs pour décider sur quel nœud placer le pod
- **Garantie** : Le conteneur est garanti d'avoir au moins ces ressources disponibles
- **Réservation** : Ces ressources sont réservées sur le nœud, même si le conteneur ne les utilise pas

**Exemple :**
Si un nœud a 2 CPU disponibles et que vous demandez `cpu: 100m`, Kubernetes sait qu'il reste `1900m` (1.9 CPU) disponibles pour d'autres pods.

---

## 3. `cpu: 100m`

### Explication de l'unité CPU

- **`m`** signifie **millicores** (millième de cœur CPU)
- **`100m`** = 0.1 CPU = 10% d'un cœur CPU
- **`1000m`** = 1 CPU complet

### Équivalences :
```
100m  = 0.1 CPU = 10% d'un cœur
500m  = 0.5 CPU = 50% d'un cœur
1000m = 1 CPU   = 100% d'un cœur (1 cœur complet)
2000m = 2 CPU   = 2 cœurs complets
```

### Autres notations possibles :
```yaml
cpu: 100m    # 0.1 CPU (notation millicores)
cpu: "0.1"   # 0.1 CPU (notation décimale)
cpu: 1       # 1 CPU complet
cpu: "1.5"   # 1.5 CPU
```

### Signification pour `cpu: 100m` :
- Le conteneur **demande** 10% d'un cœur CPU
- Kubernetes **garantit** que ce conteneur aura accès à au moins 10% d'un CPU
- Le conteneur peut utiliser **plus** si disponible (jusqu'à la limite définie)

---

## 4. `memory: 128Mi`

### Explication de l'unité Mémoire

- **`Mi`** signifie **Mebibyte** (1 Mi = 1024 Ki = 1,048,576 bytes)
- **`128Mi`** = 128 × 1,048,576 bytes ≈ 134 MB

### Unités de mémoire disponibles :

**Notation binaire (base 1024) - Préférée dans Kubernetes :**
```
Ki = Kibibyte = 1024 bytes
Mi = Mebibyte = 1024 Ki = 1,048,576 bytes
Gi = Gibibyte = 1024 Mi = 1,073,741,824 bytes
Ti = Tebibyte = 1024 Gi
```

**Notation décimale (base 1000) :**
```
k ou K = Kilobyte = 1000 bytes
M = Megabyte = 1000 K
G = Gigabyte = 1000 M
T = Terabyte = 1000 G
```

### Exemples :
```yaml
memory: 128Mi    # 128 Mebibytes ≈ 134 MB
memory: 1Gi      # 1 Gibibyte ≈ 1.07 GB
memory: 512Mi    # 512 Mebibytes ≈ 537 MB
memory: 2Gi      # 2 Gibibytes ≈ 2.15 GB
```

### Signification pour `memory: 128Mi` :
- Le conteneur **demande** 128 Mi de RAM
- Kubernetes **garantit** que ce conteneur aura accès à au moins 128 Mi
- Le conteneur peut utiliser **plus** si disponible (jusqu'à la limite)

---

## 5. `limits:`

Les **limits** (limites) définissent les **ressources maximales** qu'un conteneur peut utiliser.

### Rôle des limits :

- **Plafond** : Le conteneur ne pourra jamais dépasser ces valeurs
- **Protection** : Empêche un conteneur de monopoliser toutes les ressources du nœud
- **Throttling CPU** : Si le conteneur essaie d'utiliser plus de CPU que la limite, il sera ralenti
- **OOM Kill (mémoire)** : Si le conteneur dépasse la limite mémoire, il sera tué (Out Of Memory)

---

## 6. `cpu: 500m` (dans limits)

- Le conteneur peut utiliser **jusqu'à 50%** d'un cœur CPU
- S'il essaie d'utiliser plus, il sera **ralenti (throttled)**
- Il ne sera **jamais tué** pour excès de CPU (seulement ralenti)

### Comparaison avec request :
```yaml
requests:
  cpu: 100m    # Garantie : 10% d'un CPU
limits:
  cpu: 500m    # Maximum : 50% d'un CPU
```

Le conteneur peut **burster** entre 10% et 50% selon la disponibilité.

---

## 7. `memory: 512Mi` (dans limits)

- Le conteneur peut utiliser **jusqu'à 512 Mi** de RAM
- S'il essaie d'utiliser plus, il sera **tué (OOM Killed)**
- Kubernetes redémarrera automatiquement le conteneur

### Comparaison avec request :
```yaml
requests:
  memory: 128Mi    # Garantie : 128 Mi
limits:
  memory: 512Mi    # Maximum : 512 Mi (sera tué si dépassé)
```

Le conteneur peut utiliser entre 128 Mi et 512 Mi. Au-delà de 512 Mi, il sera terminé.

---

## Comportements détaillés

### Comportement CPU

| Situation | Comportement |
|-----------|--------------|
| Utilisation < request (100m) | Normal |
| Utilisation entre request et limit (100m - 500m) | Normal, si CPU disponible |
| Utilisation = limit (500m) | Throttling (ralentissement) |
| Tentative > limit | Throttling forcé, jamais tué |

### Comportement Mémoire

| Situation | Comportement |
|-----------|--------------|
| Utilisation < request (128Mi) | Normal |
| Utilisation entre request et limit (128Mi - 512Mi) | Normal |
| Utilisation = limit (512Mi) | Risque de terminaison |
| Utilisation > limit | **OOMKilled** - Pod redémarré |

---

## Exemples pratiques

### Exemple 1 : Application légère (API simple)

```yaml
resources:
  requests:
    cpu: 50m        # 5% CPU garanti
    memory: 64Mi    # 64 Mi garantis
  limits:
    cpu: 200m       # Max 20% CPU
    memory: 256Mi   # Max 256 Mi
```

### Exemple 2 : Application moyenne (Web app)

```yaml
resources:
  requests:
    cpu: 250m       # 25% CPU garanti
    memory: 512Mi   # 512 Mi garantis
  limits:
    cpu: 1000m      # Max 1 CPU complet
    memory: 2Gi     # Max 2 Gi
```

### Exemple 3 : Application gourmande (Base de données)

```yaml
resources:
  requests:
    cpu: 1000m      # 1 CPU complet garanti
    memory: 2Gi     # 2 Gi garantis
  limits:
    cpu: 4000m      # Max 4 CPUs
    memory: 8Gi     # Max 8 Gi
```

### Exemple 4 : Pas de limite (non recommandé)

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  # Pas de limits - le conteneur peut tout consommer
```

---

## Impact sur le scheduling

Kubernetes classe les pods en 3 catégories selon leurs ressources :

### 1. **Guaranteed** (Garanti)
```yaml
# requests = limits
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 500m
    memory: 512Mi
```
- Priorité la plus élevée
- Derniers à être évincés

### 2. **Burstable** (Votre cas)
```yaml
# requests < limits
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```
- Priorité moyenne
- Peuvent être évincés si le nœud manque de ressources

### 3. **BestEffort** (Meilleur effort)
```yaml
# Pas de requests ni limits
resources: {}
```
- Priorité la plus basse
- Premiers à être évincés

---

## Vérifier l'utilisation réelle

```bash
# Voir l'utilisation actuelle des ressources
kubectl top pod <nom-du-pod>

# Voir les événements (OOMKilled, etc.)
kubectl describe pod <nom-du-pod>

# Logs si le pod a été tué
kubectl get events --sort-by='.lastTimestamp'
```

---

## Conseils pratiques

1. **Toujours définir requests et limits** pour éviter les problèmes de ressources
2. **Commencer conservateur** puis ajuster selon les métriques réelles
3. **Requests ≈ utilisation moyenne**, **Limits ≈ pic d'utilisation**
4. **Ratio raisonnable** : limits = 2× à 4× requests
5. **Monitoring** : Utiliser Prometheus/Grafana pour observer la consommation réelle

---

## Résumé de la configuration suivante:

```yaml
resources:
  requests:
    cpu: 100m        # Garantit 10% d'un CPU
    memory: 128Mi    # Garantit 128 Mi de RAM
  limits:
    cpu: 500m        # Limite à 50% d'un CPU (throttling au-delà)
    memory: 512Mi    # Limite à 512 Mi (OOMKill au-delà)
```

Cette configuration convient à une application web légère à moyenne qui :
- Utilise normalement ~10% CPU et ~128 Mi
- Peut burster jusqu'à 50% CPU et 512 Mi lors des pics
- Sera ralentie (CPU) ou redémarrée (mémoire) si elle dépasse ces limites