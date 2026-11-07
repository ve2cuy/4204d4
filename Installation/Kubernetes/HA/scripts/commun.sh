#!/bin/bash
# ---------------------------------------------------------------------------
# Fichier:     commun.sh
# Auteur:      Alain Boudreault
# Date:        2026.11.07
# Description: Préparation d'un serveur de l'amas (contrôleur ou ouvrier) :
#              sections 2 et 3 du document 24b (swap, modules, containerd,
#              kubeadm/kubelet/kubectl, image pause).
# Variables:   K8S_VERSION (ex. v1.37), IP (adresse du réseau privé), HOSTS
# ---------------------------------------------------------------------------
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo ">>> Fichier hosts"
echo "$HOSTS" >> /etc/hosts

echo ">>> Désactiver le swap"
swapoff -a
sed -i -E 's/^([^#].*[[:space:]]swap[[:space:]].*)$/#\1/' /etc/fstab

echo ">>> Modules du noyau et réseau"
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system > /dev/null

echo ">>> containerd"
apt-get update -qq
apt-get install -y -qq containerd > /dev/null
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo ">>> kubeadm, kubelet et kubectl ${K8S_VERSION}"
apt-get install -y -qq ca-certificates curl gpg > /dev/null
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key" | gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update -qq
apt-get install -y -qq kubelet kubeadm kubectl > /dev/null
apt-mark hold kubelet kubeadm kubectl > /dev/null

echo ">>> Image pause attendue par kubeadm"
PAUSE=$(kubeadm config images list 2>/dev/null | grep pause)
sed -i "s#registry.k8s.io/pause:[0-9.]*#${PAUSE}#" /etc/containerd/config.toml
systemctl restart containerd

# Une VM Vagrant a deux cartes réseau : la première (NAT de Vagrant) a la même
# adresse sur toutes les VM. kubelet doit annoncer l'adresse du réseau privé.
echo ">>> kubelet : adresse du nœud ${IP}"
echo "KUBELET_EXTRA_ARGS=--node-ip=${IP}" > /etc/default/kubelet
systemctl restart kubelet || true

echo ">>> $(hostname) prêt : $(kubeadm version -o short), $(containerd --version | cut -d' ' -f3)"
