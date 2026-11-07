#!/bin/bash
# ---------------------------------------------------------------------------
# Fichier:     ouvrier.sh
# Auteur:      Alain Boudreault
# Date:        2026.11.07
# Description: Nœud ouvrier (worker) d'un amas HA : kubeadm join par l'IP
#              virtuelle de l'API.
# Variables:   VIP, JETON, CA_HASH
# ---------------------------------------------------------------------------
set -euo pipefail

echo ">>> Attente de l'API par l'IP virtuelle ${VIP}:6443"
for i in $(seq 1 180); do
    curl -sk --max-time 3 "https://${VIP}:6443/livez" | grep -q ok && break
    sleep 5
done

kubeadm join "${VIP}:6443" \
    --token "${JETON}" \
    --discovery-token-ca-cert-hash "${CA_HASH}"

echo ">>> $(hostname) : nœud ouvrier prêt"
