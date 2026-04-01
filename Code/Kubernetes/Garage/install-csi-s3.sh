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
