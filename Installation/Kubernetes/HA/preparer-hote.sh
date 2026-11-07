#!/bin/bash
# ---------------------------------------------------------------------------
# Fichier:     preparer-hote.sh
# Auteur:      Alain Boudreault
# Date:        2026.11.07
# Description: Prépare la VM Ubuntu Server (l'hôte des VM de l'amas HA) :
#              KVM, libvirt, micrologiciel UEFI (OVMF), Vagrant et le greffon
#              vagrant-libvirt.
# Usage:       bash preparer-hote.sh      (usager ordinaire, avec sudo)
#              puis fermer la session et se reconnecter (groupe libvirt).
# ---------------------------------------------------------------------------
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo ">>> Virtualisation matérielle"
if [ ! -e /dev/kvm ]; then
    echo "ERREUR : /dev/kvm absent. Activer la virtualisation imbriquée de la VM :"
    echo "  Hyper-V (PowerShell admin, VM arrêtée) :"
    echo "    Set-VMProcessor -VMName <VM> -ExposeVirtualizationExtensions \$true"
    exit 1
fi
echo "/dev/kvm présent, $(grep -c -E 'vmx|svm' /proc/cpuinfo) processeur(s) avec VT-x/AMD-V"

echo ">>> KVM, libvirt, OVMF et outils de compilation"
sudo apt-get update -qq
sudo apt-get install -y -qq qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-dev \
    ovmf build-essential pkg-config git curl gpg > /dev/null

echo ">>> Vagrant (dépôt apt de HashiCorp)"
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt-get update -qq
sudo apt-get install -y -qq vagrant > /dev/null

echo ">>> Greffon vagrant-libvirt (compilation : quelques minutes)"
vagrant plugin install vagrant-libvirt

echo ">>> Droits sur libvirt et KVM pour $USER"
sudo usermod -aG libvirt,kvm "$USER"

echo ">>> Réserve de stockage « default » de libvirt"
if ! sudo virsh pool-info default > /dev/null 2>&1; then
    sudo virsh pool-define-as default dir --target /var/lib/libvirt/images > /dev/null
    sudo virsh pool-start default > /dev/null
    sudo virsh pool-autostart default > /dev/null
fi

echo ">>> libvirt comme fournisseur par défaut de Vagrant"
grep -q VAGRANT_DEFAULT_PROVIDER ~/.bashrc || echo 'export VAGRANT_DEFAULT_PROVIDER=libvirt' >> ~/.bashrc

echo
echo ">>> Prêt : $(vagrant --version), $(vagrant plugin list | grep libvirt)"
echo ">>> Fermer la session et se reconnecter (groupe libvirt), puis : vagrant up"
