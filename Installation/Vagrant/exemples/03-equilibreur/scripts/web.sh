#!/bin/bash
# Serveur Web : nginx et une page qui affiche le nom de la VM
# Variables reçues du Vagrantfile : NOM, IP
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

rm -f /etc/netplan/01-netcfg.yaml   # défaut de la boîte : document 33, section 9.5

apt-get update -q
apt-get install -y -q nginx
echo "<h1>Réponse de ${NOM} (${IP})</h1>" > /var/www/html/index.html
echo ">>> ${NOM} prêt : http://${IP}"
