#!/bin/bash
# --------------------------------------------------------------
# Auteur: Alain Boudreault
# Version: 1.0
# Date: 2025.12.03
# --------------------------------------------------------------
# Script d'installation pour un noeud Kubernetes
# --------------------------------------------------------------

# --------------------------------------------------------------
# Première partie: Installation et configuration de containerd

# 1 - Chargement des modules du noyau requis
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf 
overlay 
br_netfilter 
EOF
sudo modprobe overlay 
sudo modprobe br_netfilter

# 2 - Configuration des paramètres réseau requis pour Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 2.1 – Recharger la nouvelle configuration
sudo sysctl --system

# 3 – Installer containerd
sudo apt-get update
sudo apt-get install -y containerd

# 4 – Renseigner les droits de groupe requis pour le fonctionnement de containerd
sudo mkdir -p /etc/containerd
# Créer le fichier de configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml
# Ajouter le processus à Cgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# 5 – Redémarrer et activer containerd:
sudo systemctl restart containerd
# La commande suivante assure que containerd est lancé au redémarrage du serveur
sudo systemctl enable containerd

# --------------------------------------------------------------
# Deuxième partie: Installation et configuration de Kubernetes

# 6 – Désactiver le fichier d’échange de la mémoire virtuelle:
sudo swapoff -a
# Pour rendre cette modification permanente, commenter la ligne d’échange dans /etc/fstab
sudo sed '/\tswap/ s/^\(.*\)$/#\1/g' /etc/fstab

# 7 – Ajouter le dépôt Kubernetes à la commande ‘apt’:
# Pré-requis, obtenir la liste de la dernière version stable disponible pour l'installation:
curl -Ls "https://sbom.k8s.io/$(curl -Ls https://dl.k8s.io/release/stable.txt)/release" | grep "SPDXID: SPDXRef-Package-registry.k8s.io" |  grep -v sha256 | cut -d- -f3- | sed 's/-/\//' | sed 's/-v1/:v1/'

# Utiliser la version entière pour la variable; 1.34.2 = 1.34
export K8S_VERSION=v1.34
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# 8 – Installer les paquets Kubernetes:
sudo apt-get install -y kubelet kubeadm kubectl
# Empêcher la mise à jour automatique des paquets Kubernetes
sudo apt-mark hold kubelet kubeadm kubectl

# --------------------------------------------------------------
# Fin du script d'installation pour un noeud Kubernetes
# Vérifier l'installation
kubelet --version

echo "Copier la commande suivante depuis le serveur maître pour connaitre le jeton d'accès du noeud:"
echo ""
echo "kubeadm token create --print-join-command"
echo ""
echo "Puis exécuter cette commande sur le noeud pour l'ajouter au cluster Kubernetes."