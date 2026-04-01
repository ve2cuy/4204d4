# Garage en DaemonSet Kubernetes — Guide complet

## Architecture

```
┌────────────────────────────────── namespace: garage ─────────────────────────┐
│                                                                               │
│   DaemonSet "garage"  — 1 pod par nœud labelisé "garage-node=true"          │
│                                                                               │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│   │  nœud-1     │    │  nœud-2     │    │  nœud-3     │                     │
│   │ garage pod  │    │ garage pod  │    │ garage pod  │                     │
│   │ :3900 (S3)  │    │ :3900 (S3)  │    │ :3900 (S3)  │                     │
│   │ :3901 (RPC) │◄──►│ :3901 (RPC) │◄──►│ :3901 (RPC) │                     │
│   │ :3903 admin │    │ :3903 admin │    │ :3903 admin │                     │
│   └──────┬──────┘    └──────┬──────┘    └──────┬──────┘                     │
│   /var/lib/garage   /var/lib/garage    /var/lib/garage  (hostPath)           │
│                                                                               │
│   Services :                                                                  │
│   • garage-headless  ClusterIP:None  → découverte RPC entre pods             │
│   • garage-s3        ClusterIP:3900  → API S3 interne cluster                │
│   • garage-admin     ClusterIP:3903  → API admin                             │
│                                                                               │
│   Job : garage-init-layout  → layout + bucket nginx-web + clé S3            │
└───────────────────────────────────────────────────────────────────────────────┘
                              │ garage-s3:3900
                              ▼
┌────────────────────── namespace: nginx-garage ────────────────────────────────┐
│                                                                               │
│   PV/PVC ──► CSI S3 Driver ──► bucket "nginx-web" via garage-s3:3900        │
│                                                                               │
│   ┌──────────┐   ┌──────────┐   ← Deployment, 2 réplicas, ReadOnlyMany     │
│   │ nginx-1  │   │ nginx-2  │                                               │
│   └──────────┘   └──────────┘                                               │
│              │                                                                │
│        LoadBalancer :80                                                       │
└───────────────────────────────────────────────────────────────────────────────┘
```

## Fichiers

| Fichier | Rôle |
|---------|------|
| `garage-daemonset.yaml` | DaemonSet Garage + Services + Job d'initialisation |
| `nginx-deployment.yaml` | nginx 2 réplicas + PV/PVC CSI S3 + LoadBalancer |
| `install-csi-s3.sh` | Driver CSI S3 (geesefs) pour monter les buckets K8s |

---

## Déploiement pas à pas

### 1. Générer la clé RPC et patcher la ConfigMap

```bash
RPC_SECRET=$(openssl rand -hex 32)
sed -i "s/CHANGEME_openssl_rand_hex_32/${RPC_SECRET}/" garage-daemonset.yaml
```

### 2. Labeliser les nœuds Garage

```bash
kubectl get nodes

kubectl label node <nœud-1> garage-node=true
kubectl label node <nœud-2> garage-node=true   # optionnel pour cluster multi-nœuds
```

### 3. Déployer le DaemonSet

```bash
kubectl apply -f garage-daemonset.yaml

# Attendre que les pods soient prêts
kubectl rollout status daemonset/garage -n garage --timeout=120s
kubectl get pods -n garage -o wide
```

### 4. Vérifier l'initialisation (Job automatique)

```bash
kubectl get job garage-init-layout -n garage
kubectl logs job/garage-init-layout -n garage
```

Le Job crée automatiquement le bucket `nginx-web` et la clé `nginx-s3-key`.

Pour un cluster **multi-nœuds**, assigner manuellement chaque nœud au layout :

```bash
kubectl exec -n garage ds/garage -- garage node list

kubectl exec -n garage ds/garage -- garage layout assign \
  --zone dc1 --capacity 100G <NODE_ID_1>
kubectl exec -n garage ds/garage -- garage layout assign \
  --zone dc2 --capacity 100G <NODE_ID_2>

kubectl exec -n garage ds/garage -- garage layout apply --version 1
```

### 5. Récupérer les credentials S3

```bash
kubectl exec -n garage ds/garage -- garage key info nginx-s3-key
# Notez : Key ID  et  Secret key
```

### 6. Uploader index.html via un Job K8s

```bash
ACCESS_KEY="GK..."   # Key ID récupéré ci-dessus
SECRET_KEY="..."     # Secret key récupéré ci-dessus

cat <<EOF | kubectl apply -f -
apiVersion: batch/v1
kind: Job
metadata:
  name: upload-index
  namespace: garage
spec:
  ttlSecondsAfterFinished: 60
  template:
    spec:
      restartPolicy: OnFailure
      containers:
        - name: uploader
          image: amazon/aws-cli:latest
          command: [sh, -c]
          args:
            - |
              cat > /tmp/index.html <<'HTML'
              <!DOCTYPE html>
              <html lang="fr">
              <head>
                <meta charset="UTF-8">
                <title>Nginx + Garage S3 (DaemonSet)</title>
                <style>
                  body { font-family: sans-serif; text-align: center; padding: 4rem;
                         background: #1a1a2e; color: #e0e0e0; }
                  h1 { font-size: 2.5rem; }
                  .badge { display: inline-block; padding: .4rem 1rem;
                           border-radius: 999px; margin: .3rem;
                           background: #326ce5; color: #fff; font-weight: 600; }
                </style>
              </head>
              <body>
                <h1>🚀 Nginx + Garage S3</h1>
                <p>
                  <span class="badge">nginx</span>
                  <span class="badge">Kubernetes DaemonSet</span>
                  <span class="badge">Garage S3</span>
                </p>
                <p style="color:#a0aec0;margin-top:2rem;">
                  Contenu hébergé dans le bucket nginx-web via Garage
                </p>
              </body>
              </html>
              HTML
              aws --endpoint-url http://garage-s3.garage.svc.cluster.local:3900 \
                  s3 cp /tmp/index.html s3://nginx-web/index.html \
                  --content-type "text/html; charset=utf-8"
              echo "✅ Upload terminé"
          env:
            - name: AWS_ACCESS_KEY_ID
              value: "${ACCESS_KEY}"
            - name: AWS_SECRET_ACCESS_KEY
              value: "${SECRET_KEY}"
            - name: AWS_DEFAULT_REGION
              value: garage
EOF
```

### 7. Installer le driver CSI S3

```bash
./install-csi-s3.sh
kubectl get daemonset csi-s3 -n kube-system
```

### 8. Déployer nginx

```bash
ACCESS_B64=$(echo -n "$ACCESS_KEY" | base64)
SECRET_B64=$(echo -n "$SECRET_KEY" | base64)

sed -i "s|VOTRE_ACCESS_KEY_EN_BASE64|${ACCESS_B64}|" nginx-deployment.yaml
sed -i "s|VOTRE_SECRET_KEY_EN_BASE64|${SECRET_B64}|" nginx-deployment.yaml

kubectl apply -f nginx-deployment.yaml
kubectl rollout status deployment/nginx-garage -n nginx-garage
```

### 9. Tester

```bash
EXTERNAL_IP=$(kubectl get svc nginx-lb -n nginx-garage \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl http://${EXTERNAL_IP}/
curl http://${EXTERNAL_IP}/healthz
```

---

## Commandes utiles Garage

```bash
# Status du cluster
kubectl exec -n garage ds/garage -- garage status

# Voir le layout
kubectl exec -n garage ds/garage -- garage layout show

# Lister les buckets / clés
kubectl exec -n garage ds/garage -- garage bucket list
kubectl exec -n garage ds/garage -- garage key list

# Statistiques
kubectl exec -n garage ds/garage -- garage stats

# Logs
kubectl logs -n garage -l app=garage --follow
kubectl logs -n nginx-garage -l app=nginx-garage --follow
```
