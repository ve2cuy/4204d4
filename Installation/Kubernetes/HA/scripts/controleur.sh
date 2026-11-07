#!/bin/bash
# ---------------------------------------------------------------------------
# Fichier:     controleur.sh
# Auteur:      Alain Boudreault
# Date:        2026.11.07
# Description: Contrôleur (control-plane) d'un amas HA, etcd empilé.
#              - Premier contrôleur : kubeadm init avec la CA préparée par le
#                Vagrantfile, point d'entrée = VIP, puis Flannel.
#              - Autres contrôleurs : kubeadm join --control-plane.
# Variables:   PREMIER (oui|non), IP, VIP, RESEAU, JETON, CA_HASH, CLE_CRT
# ---------------------------------------------------------------------------
set -euo pipefail

attendre_api() {
    echo ">>> Attente de l'API par l'IP virtuelle ${VIP}:6443"
    for i in $(seq 1 180); do
        curl -sk --max-time 3 "https://${VIP}:6443/livez" | grep -q ok && return 0
        sleep 5
    done
    echo "L'API ne répond pas par ${VIP}:6443" >&2; exit 1
}

if [ "$PREMIER" = "oui" ]; then
    echo ">>> CA de l'amas (préparée par le Vagrantfile)"
    mkdir -p /etc/kubernetes/pki
    install -m 644 /tmp/ca.crt /etc/kubernetes/pki/ca.crt
    install -m 600 /tmp/ca.key /etc/kubernetes/pki/ca.key
    rm -f /tmp/ca.crt /tmp/ca.key

    echo ">>> kubeadm init"
    kubeadm init \
        --control-plane-endpoint "${VIP}:6443" \
        --apiserver-advertise-address "${IP}" \
        --pod-network-cidr 10.244.0.0/16 \
        --upload-certs \
        --certificate-key "${CLE_CRT}" \
        --token "${JETON}"
else
    attendre_api
    echo ">>> kubeadm join --control-plane"
    kubeadm join "${VIP}:6443" \
        --token "${JETON}" \
        --discovery-token-ca-cert-hash "${CA_HASH}" \
        --control-plane \
        --certificate-key "${CLE_CRT}" \
        --apiserver-advertise-address "${IP}"
fi

echo ">>> kubectl pour l'usager vagrant"
mkdir -p /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

if [ "$PREMIER" = "oui" ]; then
    # Flannel doit utiliser la carte du réseau privé, pas celle du NAT de Vagrant
    echo ">>> Flannel (carte du réseau ${RESEAU}.0/24)"
    curl -fsSL https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml \
        | sed "s|- --kube-subnet-mgr|- --kube-subnet-mgr\n        - --iface-regex=^${RESEAU}\\\\.|" \
        | kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f -
    attendre_api
fi

echo ">>> $(hostname) : contrôleur prêt"
