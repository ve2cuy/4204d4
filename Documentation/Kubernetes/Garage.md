Voici les fichiers nécessaires pour déployer nginx avec Garage (stockage S3 compatible) sur Kubernetes.Voici les 6 fichiers générés. Voici le résumé de ce qui a été produit et l'ordre d'exécution :

---

## Architecture déployée

```
Internet → LoadBalancer:80 → nginx Pod 1 ─┐
                           → nginx Pod 2 ─┴→ PVC (ReadOnlyMany)
                                                    ↓
                                          CSI Driver S3 / GeeseFS
                                                    ↓
                                          Garage API S3 :3900
                                                    ↓
                                          Bucket: nginx-web/index.html
```

---

## Ordre d'exécution

**1. Sur le nœud Garage** — installer et démarrer Garage :
```bash
sudo ./install-garage.sh
sudo useradd --system --no-create-home --shell /sbin/nologin garage
sudo chown -R garage:garage /var/lib/garage
sudo cp garage.service /etc/systemd/system/
sudo systemctl enable --now garage
```

**2. Sur le nœud Garage** — créer le bucket et uploader `index.html` :
```bash
sudo ./setup-bucket.sh
# → génère /etc/garage-credentials.env avec ACCESS_KEY et SECRET_KEY
```

**3. Sur votre machine kubectl** — installer le driver CSI S3 :
```bash
# Adapter GARAGE_ENDPOINT dans le script, puis :
./install-csi-s3.sh
```

**4. Mettre les credentials en base64** dans `nginx-deployment.yaml` (section Secret), puis déployer :
```bash
kubectl apply -f nginx-deployment.yaml
kubectl get svc nginx-garage-lb -n nginx-garage
```

---

## Points clés du YAML

- **StorageClass** `garage-s3-storage` avec driver CSI `ru.yandex.s3.csi` et mounter `geesefs` (FUSE haute perf)
- **PV/PVC** en `ReadOnlyMany` — partagé entre les 2 réplicas sans conflit d'écriture
- **Deployment** avec `podAntiAffinity` pour placer les pods sur des nœuds différents
- **ConfigMap** nginx avec health check `/healthz` pour les probes du LoadBalancer
- **HPA** optionnel (min 2, max 5 réplicas selon CPU)

---

## Le fichier yaml

```
# =============================================================================
# Déploiement Nginx — 2 réplicas avec stockage S3 via Garage
# Prérequis : driver CSI S3 installé (https://github.com/yandex-cloud/k8s-csi-s3)
#             et Secret "garage-s3-credentials" créé (voir setup-bucket.sh)
# =============================================================================

---
# ─── Namespace dédié ─────────────────────────────────────────────────────────
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-garage
  labels:
    app.kubernetes.io/managed-by: kubectl

---
# ─── Secret : credentials Garage S3 ──────────────────────────────────────────
# IMPORTANT : Remplacez les valeurs par les vraies clés générées par setup-bucket.sh
# Valeurs encodées en base64 : echo -n "valeur" | base64
apiVersion: v1
kind: Secret
metadata:
  name: garage-s3-credentials
  namespace: nginx-garage
type: Opaque
data:
  # Remplacer par : echo -n "VOTRE_ACCESS_KEY" | base64
  access-key: VOTRE_ACCESS_KEY_EN_BASE64
  # Remplacer par : echo -n "VOTRE_SECRET_KEY" | base64
  secret-key: VOTRE_SECRET_KEY_EN_BASE64

---
# ─── StorageClass : CSI S3 pointant vers Garage ───────────────────────────────
# Utilise le driver github.com/yandex-cloud/k8s-csi-s3
# Installation du driver CSI : voir install-csi-s3.sh
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: garage-s3-storage
provisioner: ru.yandex.s3.csi          # nom du driver CSI S3
reclaimPolicy: Retain
volumeBindingMode: Immediate
parameters:
  mounter: geesefs                      # geesefs = montage FUSE haute perf
  options: "--memory-limit 1000 --dir-mode 0755 --file-mode 0644"
  csi.storage.k8s.io/provisioner-secret-name: garage-s3-credentials
  csi.storage.k8s.io/provisioner-secret-namespace: nginx-garage
  csi.storage.k8s.io/node-stage-secret-name: garage-s3-credentials
  csi.storage.k8s.io/node-stage-secret-namespace: nginx-garage

---
# ─── PersistentVolume : bucket nginx-web dans Garage ─────────────────────────
apiVersion: v1
kind: PersistentVolume
metadata:
  name: garage-nginx-pv
  labels:
    app: nginx-garage
    storage: garage-s3
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadOnlyMany                      # Partagé entre les 2 réplicas en lecture
  persistentVolumeReclaimPolicy: Retain
  storageClassName: garage-s3-storage
  mountOptions:
    - allow_other                       # Nécessaire pour FUSE multi-pod
  csi:
    driver: ru.yandex.s3.csi
    volumeHandle: nginx-web             # Nom du bucket Garage
    volumeAttributes:
      capacity: 10Gi
      mounter: geesefs
      options: "--memory-limit 1000 --dir-mode 0755 --file-mode 0644"
    # Endpoint de l'API S3 Garage — adapter l'IP/hostname
    nodeStageSecretRef:
      name: garage-s3-credentials
      namespace: nginx-garage
  # Variables d'environnement injectées depuis le Secret pour le CSI driver
  # Le driver CSI S3 lit S3_ENDPOINT, ACCESS_KEY_ID, SECRET_ACCESS_KEY
  # via le Secret référencé dans nodeStageSecretRef

---
# ─── PersistentVolumeClaim ────────────────────────────────────────────────────
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: garage-nginx-pvc
  namespace: nginx-garage
  labels:
    app: nginx-garage
spec:
  accessModes:
    - ReadOnlyMany
  storageClassName: garage-s3-storage
  resources:
    requests:
      storage: 10Gi
  selector:
    matchLabels:
      app: nginx-garage
      storage: garage-s3

---
# ─── ConfigMap : configuration nginx ─────────────────────────────────────────
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
  namespace: nginx-garage
data:
  nginx.conf: |
    user  nginx;
    worker_processes  auto;
    error_log  /var/log/nginx/error.log warn;
    pid        /var/run/nginx.pid;

    events {
        worker_connections  1024;
    }

    http {
        include       /etc/nginx/mime.types;
        default_type  application/octet-stream;

        log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                          '$status $body_bytes_sent "$http_referer" '
                          '"$http_user_agent"';

        access_log  /var/log/nginx/access.log  main;

        sendfile        on;
        keepalive_timeout  65;
        gzip  on;

        server {
            listen       80;
            server_name  _;

            # Racine web = point de montage du bucket S3
            root   /usr/share/nginx/html;
            index  index.html index.htm;

            location / {
                try_files $uri $uri/ /index.html;
            }

            # Headers de sécurité
            add_header X-Content-Type-Options "nosniff" always;
            add_header X-Frame-Options "SAMEORIGIN" always;
            add_header X-XSS-Protection "1; mode=block" always;

            # Page d'erreur personnalisée
            error_page 404 /error.html;
            location = /error.html {
                internal;
            }

            # Health check endpoint pour le LoadBalancer
            location /healthz {
                access_log off;
                return 200 "OK\n";
                add_header Content-Type text/plain;
            }
        }
    }

---
# ─── Deployment : 2 réplicas nginx ───────────────────────────────────────────
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-garage
  namespace: nginx-garage
  labels:
    app: nginx-garage
    version: "1.0"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-garage
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0               # Zéro downtime lors des mises à jour
  template:
    metadata:
      labels:
        app: nginx-garage
        version: "1.0"
      annotations:
        prometheus.io/scrape: "false"
    spec:
      # Répartir les pods sur des nœuds différents pour la HA
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - nginx-garage
                topologyKey: kubernetes.io/hostname

      containers:
        - name: nginx
          image: nginx:1.27-alpine
          ports:
            - containerPort: 80
              protocol: TCP
              name: http

          # Montage du bucket S3 Garage comme racine web
          volumeMounts:
            - name: web-content
              mountPath: /usr/share/nginx/html
              readOnly: true
            - name: nginx-config
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
              readOnly: true

          # Probes de santé
          livenessProbe:
            httpGet:
              path: /healthz
              port: 80
            initialDelaySeconds: 10
            periodSeconds: 15
            failureThreshold: 3

          readinessProbe:
            httpGet:
              path: /healthz
              port: 80
            initialDelaySeconds: 5
            periodSeconds: 10
            failureThreshold: 3

          resources:
            requests:
              cpu: "100m"
              memory: "64Mi"
            limits:
              cpu: "500m"
              memory: "256Mi"

          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: false  # nginx écrit dans /var/cache/nginx
            runAsNonRoot: false            # nginx nécessite root pour bind :80
            capabilities:
              drop:
                - ALL
              add:
                - NET_BIND_SERVICE

      volumes:
        # Volume monté depuis le bucket Garage S3 via CSI
        - name: web-content
          persistentVolumeClaim:
            claimName: garage-nginx-pvc
        # Configuration nginx depuis ConfigMap
        - name: nginx-config
          configMap:
            name: nginx-config

      terminationGracePeriodSeconds: 30

---
# ─── Service : LoadBalancer ───────────────────────────────────────────────────
apiVersion: v1
kind: Service
metadata:
  name: nginx-garage-lb
  namespace: nginx-garage
  labels:
    app: nginx-garage
  annotations:
    # Pour cloud providers — décommenter selon l'environnement :
    # AWS : service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    # GCP : cloud.google.com/load-balancer-type: "External"
    # Azure : service.beta.kubernetes.io/azure-load-balancer-sku: standard
    # MetalLB (bare-metal) : metallb.universe.tf/address-pool: default
spec:
  type: LoadBalancer
  selector:
    app: nginx-garage
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
  # sessionAffinity: None = distribution round-robin entre les 2 réplicas
  sessionAffinity: None

---
# ─── HorizontalPodAutoscaler (optionnel) ────────────────────────────────────
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-garage-hpa
  namespace: nginx-garage
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-garage
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

---

## Installer Garage

```
#!/bin/bash
# =============================================================================
# Installation et configuration de Garage (stockage S3 compatible)
# https://garagehq.deuxfleurs.fr/
# =============================================================================
set -e

GARAGE_VERSION="v1.0.1"
GARAGE_BIN="/usr/local/bin/garage"
GARAGE_DATA="/var/lib/garage"
GARAGE_CONFIG="/etc/garage.toml"

echo ">>> Installation de Garage ${GARAGE_VERSION}..."

# Détecter l'architecture
ARCH=$(uname -m)
case $ARCH in
  x86_64)  GARAGE_ARCH="x86_64-unknown-linux-musl" ;;
  aarch64) GARAGE_ARCH="aarch64-unknown-linux-musl" ;;
  *)       echo "Architecture non supportée: $ARCH"; exit 1 ;;
esac

# Télécharger le binaire
curl -fsSL \
  "https://garagehq.deuxfleurs.fr/_releases/${GARAGE_VERSION}/${GARAGE_ARCH}/garage" \
  -o "${GARAGE_BIN}"

chmod +x "${GARAGE_BIN}"
echo ">>> Garage installé: $(garage --version)"

# Créer les répertoires
mkdir -p "${GARAGE_DATA}/meta"
mkdir -p "${GARAGE_DATA}/data"

# Générer une clé secrète sécurisée
RPC_SECRET=$(openssl rand -hex 32)

# Récupérer l'IP de la machine
NODE_IP=$(hostname -I | awk '{print $1}')

echo ">>> Création de la configuration..."
cat > "${GARAGE_CONFIG}" <<EOF
# Configuration Garage - Stockage S3 compatible
metadata_dir = "${GARAGE_DATA}/meta"
data_dir = "${GARAGE_DATA}/data"

# Clé secrète RPC partagée entre les noeuds (garder secrète !)
rpc_secret = "${RPC_SECRET}"

# Liaison réseau
rpc_bind_addr = "[::]:3901"
rpc_public_addr = "${NODE_IP}:3901"

# API S3
[s3_api]
s3_region = "garage"
api_bind_addr = "[::]:3900"
root_domain = ".s3.garage.local"

# API Web (pour hébergement web statique)
[s3_web]
bind_addr = "[::]:3902"
root_domain = ".web.garage.local"

# API Admin
[admin]
api_bind_addr = "[::]:3903"
EOF

echo ">>> Configuration créée dans ${GARAGE_CONFIG}"
echo ""
echo "    RPC_SECRET: ${RPC_SECRET}"
echo "    (Conservez ce secret si vous ajoutez d'autres noeuds)"
```

## Setup bucket

```
#!/bin/bash
# =============================================================================
# Configuration du cluster Garage : bucket, clés d'accès, et fichier index.html
# À exécuter UNE FOIS que Garage est démarré et le layout appliqué
# =============================================================================
set -e

BUCKET_NAME="nginx-web"
REGION="garage"
GARAGE_S3_ENDPOINT="http://localhost:3900"

echo ">>> Attente du démarrage de Garage..."
for i in $(seq 1 15); do
  if garage status &>/dev/null; then break; fi
  echo "    Tentative $i/15..."
  sleep 3
done

# ─── 1. Layout du cluster (nœud unique) ───────────────────────────────────────
echo ""
echo ">>> Configuration du layout du cluster (nœud unique)..."

NODE_ID=$(garage node id 2>/dev/null | head -1 | awk '{print $1}')
if [ -z "$NODE_ID" ]; then
  echo "ERREUR: impossible de récupérer l'ID du nœud. Garage est-il démarré ?"
  exit 1
fi

echo "    Nœud détecté: ${NODE_ID}"

garage layout assign \
  --zone "dc1" \
  --capacity 10G \
  "${NODE_ID}"

garage layout apply --version 1
echo "    Layout appliqué."

# ─── 2. Création du bucket ────────────────────────────────────────────────────
echo ""
echo ">>> Création du bucket '${BUCKET_NAME}'..."
garage bucket create "${BUCKET_NAME}" || echo "    (bucket déjà existant)"

# Activer l'hébergement web statique
garage bucket website \
  --allow \
  --index-document index.html \
  --error-document error.html \
  "${BUCKET_NAME}"

echo "    Bucket configuré pour l'hébergement web statique."

# ─── 3. Clé d'accès S3 ───────────────────────────────────────────────────────
echo ""
echo ">>> Création d'une clé d'accès S3..."
KEY_OUTPUT=$(garage key create nginx-s3-key 2>&1)
echo "${KEY_OUTPUT}"

ACCESS_KEY=$(echo "${KEY_OUTPUT}" | grep "Key ID:" | awk '{print $3}')
SECRET_KEY=$(echo "${KEY_OUTPUT}" | grep "Secret key:" | awk '{print $3}')

if [ -z "$ACCESS_KEY" ]; then
  echo "    Récupération des clés existantes..."
  garage key info nginx-s3-key || true
  ACCESS_KEY=$(garage key list | grep nginx-s3-key | awk '{print $1}')
fi

# Lier la clé au bucket avec les permissions lecture/écriture
garage bucket allow \
  --read \
  --write \
  --owner \
  --key nginx-s3-key \
  "${BUCKET_NAME}"

echo ""
echo "    ACCESS_KEY: ${ACCESS_KEY}"
echo "    SECRET_KEY: ${SECRET_KEY}"

# Sauvegarder les credentials
cat > /etc/garage-credentials.env <<EOF
GARAGE_ACCESS_KEY=${ACCESS_KEY}
GARAGE_SECRET_KEY=${SECRET_KEY}
GARAGE_ENDPOINT=${GARAGE_S3_ENDPOINT}
GARAGE_BUCKET=${BUCKET_NAME}
GARAGE_REGION=${REGION}
EOF
chmod 600 /etc/garage-credentials.env
echo ""
echo "    Credentials sauvegardés dans /etc/garage-credentials.env"

# ─── 4. Installation de AWS CLI (pour uploader les fichiers) ──────────────────
echo ""
echo ">>> Installation de aws-cli..."
if ! command -v aws &>/dev/null; then
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -q /tmp/awscliv2.zip -d /tmp/
  /tmp/aws/install
  rm -rf /tmp/awscliv2.zip /tmp/aws/
fi

# Configurer AWS CLI pour pointer vers Garage
mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = ${ACCESS_KEY}
aws_secret_access_key = ${SECRET_KEY}
EOF

cat > ~/.aws/config <<EOF
[default]
region = ${REGION}
output = json
EOF

# ─── 5. Créer et uploader index.html ─────────────────────────────────────────
echo ""
echo ">>> Création et upload de index.html..."

cat > /tmp/index.html <<'HTML'
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Bienvenue — nginx + Garage S3</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', system-ui, sans-serif;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #e0e0e0;
    }
    .card {
      background: rgba(255,255,255,0.05);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255,255,255,0.1);
      border-radius: 16px;
      padding: 3rem 4rem;
      text-align: center;
      max-width: 600px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.3);
    }
    .logo { font-size: 4rem; margin-bottom: 1rem; }
    h1 { font-size: 2rem; font-weight: 700; color: #fff; margin-bottom: 0.5rem; }
    .subtitle { color: #a0aec0; margin-bottom: 2rem; font-size: 1.1rem; }
    .badges { display: flex; gap: 0.75rem; justify-content: center; flex-wrap: wrap; margin-bottom: 2rem; }
    .badge {
      padding: 0.4rem 1rem;
      border-radius: 999px;
      font-size: 0.85rem;
      font-weight: 600;
      letter-spacing: 0.05em;
    }
    .badge-nginx  { background: #009639; color: #fff; }
    .badge-k8s    { background: #326ce5; color: #fff; }
    .badge-garage { background: #e25822; color: #fff; }
    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; text-align: left; }
    .info-item { background: rgba(255,255,255,0.05); border-radius: 8px; padding: 1rem; }
    .info-label { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.1em; color: #718096; margin-bottom: 0.25rem; }
    .info-value { font-weight: 600; color: #e2e8f0; font-size: 0.95rem; }
    footer { margin-top: 2rem; font-size: 0.8rem; color: #4a5568; }
  </style>
</head>
<body>
  <div class="card">
    <div class="logo">🚀</div>
    <h1>Déploiement réussi !</h1>
    <p class="subtitle">Nginx servi depuis le stockage objet S3 Garage</p>

    <div class="badges">
      <span class="badge badge-nginx">nginx</span>
      <span class="badge badge-k8s">Kubernetes</span>
      <span class="badge badge-garage">Garage S3</span>
    </div>

    <div class="info-grid">
      <div class="info-item">
        <div class="info-label">Réplicas</div>
        <div class="info-value">2 pods actifs</div>
      </div>
      <div class="info-item">
        <div class="info-label">Stockage</div>
        <div class="info-value">Bucket S3 Garage</div>
      </div>
      <div class="info-item">
        <div class="info-label">Service</div>
        <div class="info-value">LoadBalancer</div>
      </div>
      <div class="info-item">
        <div class="info-label">Volume</div>
        <div class="info-value">PersistentVolume CSI</div>
      </div>
    </div>

    <footer>Contenu hébergé dans le bucket nginx-web — Garage v1.0</footer>
  </div>
</body>
</html>
HTML

# Upload vers le bucket
aws --endpoint-url="${GARAGE_S3_ENDPOINT}" \
    s3 cp /tmp/index.html "s3://${BUCKET_NAME}/index.html" \
    --content-type "text/html; charset=utf-8"

# Créer aussi une page d'erreur
cat > /tmp/error.html <<'HTML'
<!DOCTYPE html>
<html lang="fr">
<head><meta charset="UTF-8"><title>404 - Page introuvable</title></head>
<body style="font-family:sans-serif;text-align:center;padding:4rem;">
  <h1>404 — Page introuvable</h1>
  <p>Le contenu demandé n'existe pas dans ce bucket.</p>
</body>
</html>
HTML

aws --endpoint-url="${GARAGE_S3_ENDPOINT}" \
    s3 cp /tmp/error.html "s3://${BUCKET_NAME}/error.html" \
    --content-type "text/html; charset=utf-8"

echo ""
echo "✅ Configuration terminée !"
echo ""
echo "   Bucket   : ${BUCKET_NAME}"
echo "   Endpoint : ${GARAGE_S3_ENDPOINT}"
echo "   Fichiers : index.html, error.html"
echo ""
echo ">>> Prochaine étape: créer le Secret Kubernetes avec les credentials"
echo "    kubectl create secret generic garage-s3-credentials \\"
echo "      --from-literal=access-key=${ACCESS_KEY} \\"
echo "      --from-literal=secret-key=${SECRET_KEY}"
```

## Installer csi S3

```
#!/bin/bash
# =============================================================================
# Installation du driver CSI S3 (yandex-cloud/k8s-csi-s3)
# Ce driver permet de monter un bucket S3/Garage comme volume Kubernetes
# https://github.com/yandex-cloud/k8s-csi-s3
# =============================================================================
set -e

GARAGE_ENDPOINT="http://192.168.1.100:3900"    # ← Adapter à votre IP Garage
GARAGE_REGION="garage"
NAMESPACE="kube-system"

echo ">>> Installation du driver CSI S3..."

# ─── 1. Créer le Secret pour le driver CSI ────────────────────────────────────
# Charger les credentials depuis le fichier généré par setup-bucket.sh
if [ -f /etc/garage-credentials.env ]; then
  source /etc/garage-credentials.env
else
  echo "ERREUR: /etc/garage-credentials.env introuvable."
  echo "Exécutez d'abord setup-bucket.sh sur le nœud Garage."
  exit 1
fi

echo ">>> Création du Secret CSI dans Kubernetes..."
kubectl create secret generic csi-s3-secret \
  --namespace="${NAMESPACE}" \
  --from-literal=accessKeyID="${GARAGE_ACCESS_KEY}" \
  --from-literal=secretAccessKey="${GARAGE_SECRET_KEY}" \
  --from-literal=endpoint="${GARAGE_ENDPOINT}" \
  --from-literal=region="${GARAGE_REGION}" \
  --dry-run=client -o yaml | kubectl apply -f -

# ─── 2. Appliquer les manifests du driver CSI ────────────────────────────────
echo ""
echo ">>> Déploiement du driver CSI S3..."

# ServiceAccount + ClusterRole pour le provisioner
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: csi-s3
  namespace: kube-system
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: csi-s3
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list"]
  - apiGroups: [""]
    resources: ["nodes"]
    verbs: ["get", "list", "update"]
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["get", "list"]
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["csinodes"]
    verbs: ["get", "list", "watch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: csi-s3
subjects:
  - kind: ServiceAccount
    name: csi-s3
    namespace: kube-system
roleRef:
  kind: ClusterRole
  name: csi-s3
  apiGroup: rbac.authorization.k8s.io
EOF

# DaemonSet du node plugin CSI
kubectl apply -f - <<EOF
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: csi-s3
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: csi-s3
  template:
    metadata:
      labels:
        app: csi-s3
    spec:
      serviceAccountName: csi-s3
      hostNetwork: true
      containers:
        - name: driver-registrar
          image: registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.9.0
          args:
            - "--v=5"
            - "--csi-address=/csi/csi.sock"
            - "--kubelet-registration-path=/var/lib/kubelet/plugins/ru.yandex.s3.csi/csi.sock"
          volumeMounts:
            - name: plugin-dir
              mountPath: /csi
            - name: registration-dir
              mountPath: /registration

        - name: csi-s3
          image: cr.yandex/crpqfnptqnpugvksqbfp/csi-s3:latest
          imagePullPolicy: Always
          args:
            - "--v=5"
            - "--endpoint=unix:///csi/csi.sock"
          env:
            - name: CSI_ENDPOINT
              value: unix:///csi/csi.sock
          securityContext:
            privileged: true
          volumeMounts:
            - name: plugin-dir
              mountPath: /csi
            - name: pods-mount-dir
              mountPath: /var/lib/kubelet/pods
              mountPropagation: Bidirectional
            - name: fuse-device
              mountPath: /dev/fuse

      volumes:
        - name: registration-dir
          hostPath:
            path: /var/lib/kubelet/plugins_registry/
            type: DirectoryOrCreate
        - name: plugin-dir
          hostPath:
            path: /var/lib/kubelet/plugins/ru.yandex.s3.csi
            type: DirectoryOrCreate
        - name: pods-mount-dir
          hostPath:
            path: /var/lib/kubelet/pods
            type: Directory
        - name: fuse-device
          hostPath:
            path: /dev/fuse
EOF

echo ""
echo "✅ Driver CSI S3 installé !"
echo ""
echo ">>> Vérification..."
kubectl get daemonset csi-s3 -n kube-system
echo ""
echo ">>> Prochaine étape : déployer nginx"
echo "    kubectl apply -f nginx-deployment.yaml"
```

---

## README.md

# Nginx + Garage S3 sur Kubernetes — Guide complet

## Architecture

```
Internet
   │
   ▼
[LoadBalancer : port 80]
   │
   ├──► [nginx Pod 1]  ─┐
   │                    ├──► PVC (ReadOnlyMany)
   └──► [nginx Pod 2]  ─┘         │
                                  ▼
                        [CSI Driver S3 / GeeseFS]
                                  │
                                  ▼
                        [Garage — API S3 :3900]
                                  │
                                  ▼
                        [Bucket: nginx-web]
                        ├── index.html
                        └── error.html
```

## Prérequis

- Kubernetes ≥ 1.26
- `kubectl` configuré
- `curl`, `openssl` sur le nœud Garage
- Le nœud Garage doit être accessible depuis les workers Kubernetes

---

## Étape 1 — Installer Garage sur un nœud dédié

```bash
chmod +x install-garage.sh
sudo ./install-garage.sh
```

Le script installe le binaire, crée `/etc/garage.toml` et génère une clé RPC.

### Créer l'utilisateur système et démarrer le service

```bash
# Créer l'utilisateur garage
sudo useradd --system --no-create-home --shell /sbin/nologin garage
sudo chown -R garage:garage /var/lib/garage

# Installer et activer le service systemd
sudo cp garage.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now garage

# Vérifier le statut
sudo systemctl status garage
sudo garage status
```

---

## Étape 2 — Configurer le bucket et créer index.html

```bash
chmod +x setup-bucket.sh
sudo ./setup-bucket.sh
```

Ce script :
1. Configure le layout du cluster (nœud unique, zone `dc1`)
2. Crée le bucket `nginx-web` avec l'hébergement web statique activé
3. Crée une clé d'accès S3 avec permissions lecture/écriture
4. Installe `aws-cli` et uploade `index.html` et `error.html` dans le bucket
5. Sauvegarde les credentials dans `/etc/garage-credentials.env`

### Vérifier le contenu du bucket

```bash
source /etc/garage-credentials.env
aws --endpoint-url="${GARAGE_ENDPOINT}" s3 ls "s3://${GARAGE_BUCKET}/"
```

---

## Étape 3 — Installer le driver CSI S3 dans Kubernetes

```bash
# Adapter l'IP Garage dans le script
nano install-csi-s3.sh   # Modifier GARAGE_ENDPOINT

chmod +x install-csi-s3.sh
./install-csi-s3.sh
```

Vérifier que le DaemonSet est prêt :

```bash
kubectl get daemonset csi-s3 -n kube-system
kubectl get pods -n kube-system -l app=csi-s3
```

---

## Étape 4 — Créer le Secret Kubernetes avec les credentials Garage

```bash
# Récupérer les valeurs générées par setup-bucket.sh
source /etc/garage-credentials.env   # sur le nœud Garage

# Encoder en base64
ACCESS_KEY_B64=$(echo -n "$GARAGE_ACCESS_KEY" | base64)
SECRET_KEY_B64=$(echo -n "$GARAGE_SECRET_KEY" | base64)

echo "access-key: $ACCESS_KEY_B64"
echo "secret-key: $SECRET_KEY_B64"
```

Mettre à jour les valeurs dans `nginx-deployment.yaml` (section Secret) :

```yaml
data:
  access-key: <ACCESS_KEY_B64>
  secret-key: <SECRET_KEY_B64>
```

---

## Étape 5 — Déployer nginx

```bash
kubectl apply -f nginx-deployment.yaml

# Suivre le déploiement
kubectl rollout status deployment/nginx-garage -n nginx-garage

# Vérifier les pods
kubectl get pods -n nginx-garage -o wide

# Obtenir l'IP du LoadBalancer
kubectl get svc nginx-garage-lb -n nginx-garage
```

---

## Vérification finale

```bash
# Obtenir l'IP externe
EXTERNAL_IP=$(kubectl get svc nginx-garage-lb -n nginx-garage \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Tester
curl -I "http://${EXTERNAL_IP}/"
curl "http://${EXTERNAL_IP}/healthz"
```

Ouvrir `http://<EXTERNAL_IP>/` dans un navigateur — la page d'accueil nginx s'affiche.

---

## Mettre à jour le contenu web

Pour modifier le contenu, uploadez directement dans le bucket :

```bash
source /etc/garage-credentials.env

# Uploader un fichier
aws --endpoint-url="${GARAGE_ENDPOINT}" \
    s3 cp ma-page.html "s3://${GARAGE_BUCKET}/ma-page.html"

# Synchroniser un répertoire complet
aws --endpoint-url="${GARAGE_ENDPOINT}" \
    s3 sync ./mon-site/ "s3://${GARAGE_BUCKET}/" \
    --delete
```

Les pods nginx voient les changements immédiatement (via le montage FUSE GeeseFS).

---

## Commandes de diagnostic

```bash
# Logs des pods nginx
kubectl logs -l app=nginx-garage -n nginx-garage --follow

# État des volumes
kubectl get pv,pvc -n nginx-garage

# Événements
kubectl describe pod -l app=nginx-garage -n nginx-garage

# Status Garage
garage status
garage bucket info nginx-web
garage stats
```

---

## Fichiers fournis

| Fichier                | Rôle                                              |
|------------------------|---------------------------------------------------|
| `install-garage.sh`    | Installe le binaire Garage et crée la config      |
| `garage.service`       | Unit systemd pour démarrer Garage en service      |
| `setup-bucket.sh`      | Crée le bucket, les clés et uploade index.html    |
| `install-csi-s3.sh`    | Installe le driver CSI S3 dans Kubernetes         |
| `nginx-deployment.yaml`| Tous les manifests Kubernetes (NS, SC, PV, PVC,   |
|                        | ConfigMap, Deployment, Service, HPA)              |