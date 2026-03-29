---

## Volume hostPath

Un volume `hostPath` monte un **fichier ou répertoire du nœud hôte** directement dans le Pod.


**Exemple basique**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mon-pod
spec:
  containers:
    - name: mon-app
      image: nginx
      volumeMounts:
        - mountPath: /data
          name: host-volume
  volumes:
    - name: host-volume
      hostPath:
        path: /mnt/data      # Chemin sur le nœud
        type: DirectoryOrCreate
```

---

**Les types disponibles**

| Type | Comportement |
|---|---|
| `""` (vide) | Aucune vérification, chemin doit exister |
| `Directory` | Le répertoire doit **déjà exister** |
| `DirectoryOrCreate` | Crée le répertoire s'il n'existe pas |
| `File` | Le fichier doit **déjà exister** |
| `FileOrCreate` | Crée le fichier s'il n'existe pas |
| `Socket` | Un socket Unix doit exister |
| `CharDevice` | Un périphérique caractère doit exister |
| `BlockDevice` | Un périphérique bloc doit exister |

---

**Cas d'usage typiques**
```yaml
# Accès aux logs du nœud
volumes:
  - name: logs
    hostPath:
      path: /var/log
      type: Directory

# Accès au socket Docker
volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
      type: Socket

# Accès au socket containerd
volumes:
  - name: containerd-socket
    hostPath:
      path: /run/containerd/containerd.sock
      type: Socket
```

---

**⚠️ Limitations importantes**

**Pas partagé entre nœuds**
```
Node 1            Node 2
/mnt/data  ≠     /mnt/data
(Pod A)          (Pod B)
```
Si ton Deployment a plusieurs réplicas sur des nœuds différents, chaque Pod voit **son propre** `/mnt/data` local.

**Risques de sécurité**
- Un Pod malveillant pourrait accéder à **tout le système de fichiers** du nœud
- Déconseillé en production sauf cas très spécifiques

---

**Comparaison avec les autres volumes**

| Volume | Persistance | Partagé entre nœuds | Usage |
|---|---|---|---|
| `hostPath` | Oui (sur le nœud) | ❌ Non | Debug, DaemonSet |
| `emptyDir` | Non (vie du Pod) | ❌ Non | Cache temporaire |
| `PVC` | Oui | ✅ Possible | Production |
| `configMap` | N/A | ✅ Oui | Configuration |

---

**Quand l'utiliser ?**
- Dans un **DaemonSet** (collecte de logs, monitoring) — le Pod tourne sur chaque nœud donc le `hostPath` est cohérent
- Pour accéder aux **sockets système** (`docker.sock`, `containerd.sock`)
- En **développement local** (Docker Desktop, Minikube)
- **Jamais** pour partager des données entre réplicas en production

---


## Quelle est la différence entre emptyDir et hostPath?


**`emptyDir` — Stockage lié au Pod**
```
Pod démarre  →  emptyDir créé (vide)
Pod s'arrête →  emptyDir détruit ✗
```
- Kubernetes gère l'emplacement automatiquement
- Tu ne sais pas (et n'as pas besoin de savoir) où c'est sur le nœud
- Sert à **partager des fichiers entre conteneurs du même Pod**

---

**`hostPath` — Stockage lié au Nœud**
```
Pod démarre  →  hostPath monté depuis /mon/chemin
Pod s'arrête →  /mon/chemin reste intact sur le nœud ✓
Pod redémarre → retrouve les mêmes fichiers ✓
```
- **Toi** tu choisis le chemin sur le nœud
- Les données **survivent** à la mort du Pod
- Sert à **accéder ou persister des fichiers sur le nœud**

---

**Analogie concrète**

| | emptyDir | hostPath |
|---|---|---|
| 🏨 Analogie | Tableau blanc dans une salle de réunion — **effacé après la réunion** | Clé USB branchée sur l'ordi — **les fichiers restent** après le meeting |
| Créé par | Kubernetes automatiquement | Toi, sur le nœud |
| Survit au Pod ? | ❌ Non | ✅ Oui |
| Chemin connu ? | ❌ Non | ✅ Oui (`/mon/chemin`) |

---

**Exemple visuel**

```
# emptyDir
Pod A (vivant)          Pod A (mort)
┌──────────────┐        ┌──────────────┐
│  /tmp/cache  │  →→→   │   DÉTRUIT    │
│  [fichiers]  │        │              │
└──────────────┘        └──────────────┘


# hostPath
Pod A (vivant)          Pod A (mort)         Pod A (redémarré)
┌──────────────┐        ┌──────────────┐     ┌──────────────┐
│  /data       │        │   DÉTRUIT    │     │  /data       │
│  [fichiers]  │  →→→   │              │ →→→ │  [fichiers]  │ ✓
└──────────────┘        └──────────────┘     └──────────────┘
       │                                            │
       └──────── /mnt/data sur le nœud ────────────┘
                    (toujours là)
```

---

**En une phrase :**
- `emptyDir` = **mémoire temporaire du Pod** (disparaît avec lui)
- `hostPath` = **disque dur du nœud** (persiste après lui)

---

## Faut-il créer le dossier avant de l'utiliser?

---

**Non, pas besoin de créer manuellement** → avec `DirectoryOrCreate` ou `FileOrCreate`
```yaml
volumes:
  - name: mon-volume
    hostPath:
      path: /mnt/data
      type: DirectoryOrCreate  # Kubernetes crée le dossier si absent
```

---

**Oui, le dossier doit exister** → avec `Directory` ou `""` (vide)
```yaml
volumes:
  - name: mon-volume
    hostPath:
      path: /mnt/data
      type: Directory  # Erreur si le dossier n'existe pas !
```

---

**Résumé rapide**

| Type | Dossier doit exister ? |
|---|---|
| `DirectoryOrCreate` | ❌ Non, créé automatiquement |
| `FileOrCreate` | ❌ Non, créé automatiquement |
| `Directory` | ✅ Oui obligatoire |
| `File` | ✅ Oui obligatoire |
| `""` (vide) | ✅ Oui obligatoire |

---

**Recommandation**

En pratique, utilise presque toujours `DirectoryOrCreate` pour éviter les erreurs de démarrage du Pod :

```yaml
hostPath:
  path: /mnt/data
  type: DirectoryOrCreate  # ← safe par défaut
```

Si le dossier existe déjà, Kubernetes le monte simplement sans le modifier.

---

## Services de stockage

### MinIO

Voici un exemple de PVC avec un stockage S3 local via **MinIO** (l'implémentation S3 la plus courante en local sur K8S) :

**1. Déployer MinIO**
```yaml
# minio-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: storage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
        - name: minio
          image: minio/minio:latest
          args:
            - server
            - /data
            - --console-address
            - ":9001"
          env:
            - name: MINIO_ROOT_USER
              value: "minioadmin"
            - name: MINIO_ROOT_PASSWORD
              value: "minioadmin"
          ports:
            - containerPort: 9000  # API S3
            - containerPort: 9001  # Console web
          volumeMounts:
            - name: minio-storage
              mountPath: /data
      volumes:
        - name: minio-storage
          persistentVolumeClaim:
            claimName: minio-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: storage
spec:
  selector:
    app: minio
  ports:
    - name: api
      port: 9000
      targetPort: 9000
    - name: console
      port: 9001
      targetPort: 9001
```

---

**2. PersistentVolume + PVC pour MinIO**
```yaml
# minio-pvc.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: minio-pv
spec:
  capacity:
    storage: 50Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/minio-data   # Chemin sur le nœud
  persistentVolumeReclaimPolicy: Retain
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pvc
  namespace: storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
```

---

**3. Utiliser MinIO depuis un Pod applicatif**
```yaml
# app-deployment.yaml
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
        - name: mon-app
          image: mon-app:latest
          env:
            - name: S3_ENDPOINT
              value: "http://minio.storage.svc.cluster.local:9000"
            - name: S3_ACCESS_KEY
              valueFrom:
                secretKeyRef:
                  name: minio-secret
                  key: access-key
            - name: S3_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: minio-secret
                  key: secret-key
            - name: S3_BUCKET
              value: "mon-bucket"
```

---

**4. Secret pour les credentials**
```yaml
# minio-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
type: Opaque
stringData:
  access-key: minioadmin
  secret-key: minioadmin
```

---

**Architecture résultante :**
```
Pods applicatifs (replicas)
        │
        │  SDK S3 standard
        ▼
  MinIO Service (ClusterIP)
  minio.storage.svc:9000
        │
        ▼
  MinIO Pod
        │
        ▼
  PVC → PV → /mnt/minio-data (nœud)
```

**Points clés :**
- Les Pods applicatifs utilisent le **SDK S3 standard** — aucun changement de code si tu migres vers AWS S3 plus tard
- MinIO expose une **API 100% compatible S3**
- Le PVC est monté sur MinIO uniquement — les Pods applicatifs accèdent au stockage **via HTTP**, pas via un montage de volume direct
- Pour la production multi-nœuds, remplace le `hostPath` par un **StorageClass** distribué (Longhorn, Rook-Ceph)

---


### Garage

Voici un exemple avec **Garage**, une alternative légère et distribuée à MinIO, très adaptée pour un cluster K8S multi-nœuds :Garage est un stockage objet distribué compatible S3, conçu pour le self-hosting à petite et moyenne échelle. Voici un exemple complet de déploiement sur Kubernetes :

---

**1. Namespace + Secret RPC**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: garage
---
apiVersion: v1
kind: Secret
metadata:
  name: garage-rpc-secret
  namespace: garage
type: Opaque
stringData:
  rpc-secret: "votre_secret_hex_32_bytes"  # openssl rand -hex 32
```

---

**2. ConfigMap (garage.toml)**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: garage-config
  namespace: garage
data:
  garage.toml: |
    metadata_dir = "/var/lib/garage/meta"
    data_dir = "/var/lib/garage/data"
    db_engine = "lmdb"
    replication_factor = 3
    compression_level = 2

    rpc_bind_addr = "[::]:3901"
    rpc_secret = "votre_secret_hex_32_bytes"

    [s3_api]
    s3_region = "garage"
    api_bind_addr = "[::]:3900"
    root_domain = ".s3.garage"

    [admin]
    api_bind_addr = "[::]:3903"
    admin_token = "votre_admin_token"
```

---

**3. StatefulSet (3 réplicas distribués)**
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: garage
  namespace: garage
spec:
  serviceName: garage
  replicas: 3
  selector:
    matchLabels:
      app: garage
  template:
    metadata:
      labels:
        app: garage
    spec:
      containers:
        - name: garage
          image: dxflrs/garage:v1.0.0
          ports:
            - containerPort: 3900  # S3 API
            - containerPort: 3901  # RPC
            - containerPort: 3903  # Admin
          volumeMounts:
            - name: garage-config
              mountPath: /etc/garage.toml
              subPath: garage.toml
            - name: meta
              mountPath: /var/lib/garage/meta
            - name: data
              mountPath: /var/lib/garage/data
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "2Gi"
              cpu: "1000m"
      volumes:
        - name: garage-config
          configMap:
            name: garage-config
  volumeClaimTemplates:
    - metadata:
        name: meta
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
    - metadata:
        name: data
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 50Gi
```

---

**4. Services**
```yaml
# Service headless pour le RPC inter-noeuds
apiVersion: v1
kind: Service
metadata:
  name: garage
  namespace: garage
spec:
  clusterIP: None
  selector:
    app: garage
  ports:
    - name: rpc
      port: 3901
---
# Service S3 pour les applications
apiVersion: v1
kind: Service
metadata:
  name: garage-s3
  namespace: garage
spec:
  selector:
    app: garage
  ports:
    - name: s3
      port: 3900
      targetPort: 3900
    - name: admin
      port: 3903
      targetPort: 3903
```

---

**5. Initialisation du cluster (après déploiement)**
```bash
# Vérifier le statut
kubectl exec -n garage garage-0 -- ./garage status

# Assigner chaque nœud à une zone et une capacité
kubectl exec -n garage garage-0 -- ./garage layout assign \
  -z zone1 -c 50G <node-id-0>

kubectl exec -n garage garage-0 -- ./garage layout assign \
  -z zone2 -c 50G <node-id-1>

kubectl exec -n garage garage-0 -- ./garage layout assign \
  -z zone3 -c 50G <node-id-2>

# Appliquer le layout
kubectl exec -n garage garage-0 -- ./garage layout apply --version 1

# Créer un bucket
kubectl exec -n garage garage-0 -- ./garage bucket create mon-bucket

# Créer une clé d'accès
kubectl exec -n garage garage-0 -- ./garage key create ma-cle

# Lier la clé au bucket
kubectl exec -n garage garage-0 -- ./garage bucket allow \
  --read --write --owner mon-bucket --key ma-cle
```

---

**6. Utilisation depuis un Pod applicatif**
```yaml
env:
  - name: S3_ENDPOINT
    value: "http://garage-s3.garage.svc.cluster.local:3900"
  - name: S3_REGION
    value: "garage"
  - name: S3_BUCKET
    value: "mon-bucket"
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
        name: garage-app-secret
        key: access-key
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
        name: garage-app-secret
        key: secret-key
```

---

**Architecture résultante :**
```
Pods applicatifs
      │ SDK S3 standard
      ▼
garage-s3 (Service ClusterIP :3900)
      │
      ├── garage-0 (zone1) ──┐
      ├── garage-1 (zone2)   ├── Réplication x3
      └── garage-2 (zone3) ──┘
            │          │
           PVC        PVC
          (meta)     (data)
```

---

**Différences clés vs MinIO :**

| | Garage | MinIO |
|---|---|---|
| Licence | AGPL v3 (100% libre) | AGPL v3 / commerciale |
| Multi-zones | Natif | Complexe |
| Légèreté | Très léger (Rust) | Plus lourd |
| Gestion des clés | Entités indépendantes assignables aux buckets | Liées aux utilisateurs IAM |
| Maturité | Plus récent | Plus mature |

La méthode recommandée par l'équipe Garage est d'utiliser leur chart Helm officiel, qui simplifie grandement le déploiement :

```bash
helm install --create-namespace --namespace garage \
  garage ./garage -f values.override.yaml
```