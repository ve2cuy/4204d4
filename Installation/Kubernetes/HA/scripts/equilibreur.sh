#!/bin/bash
# ---------------------------------------------------------------------------
# Fichier:     equilibreur.sh
# Auteur:      Alain Boudreault
# Date:        2026.11.07
# Description: Équilibreur de charge de l'API de Kubernetes :
#              - HAProxy répartit le port 6443 entre les contrôleurs en santé
#              - keepalived porte l'IP virtuelle (VIP) sur un des équilibreurs;
#                si celui-ci tombe, l'autre la reprend en une ou deux secondes.
# Variables:   IP, VIP, PRIORITE (le plus élevé est le maître), CPS ("nom=ip ...")
# ---------------------------------------------------------------------------
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update -qq
apt-get install -y -qq haproxy keepalived > /dev/null

echo ">>> HAProxy"
{
cat <<EOF
global
    log /dev/log local0
    maxconn 4096

defaults
    log     global
    mode    tcp
    option  tcplog
    timeout connect 5s
    timeout client  1h
    timeout server  1h

# Page de statistiques : http://<IP de l'équilibreur>:8404/
frontend stats
    mode http
    bind *:8404
    stats enable
    stats uri /
    stats refresh 5s

# API de Kubernetes
frontend k8s-api
    bind *:6443
    default_backend k8s-controleurs

backend k8s-controleurs
    balance roundrobin
    option httpchk GET /livez
    http-check expect status 200
EOF
for cp in $CPS; do
    echo "    server ${cp%%=*} ${cp#*=}:6443 check check-ssl verify none inter 3s fall 3 rise 2"
done
} > /etc/haproxy/haproxy.cfg
haproxy -c -f /etc/haproxy/haproxy.cfg
systemctl enable --now haproxy
systemctl restart haproxy

echo ">>> keepalived"
# Carte réseau qui porte l'adresse du réseau privé
IFACE=$(ip -o -4 addr show | awk -v ip="$IP" '$4 ~ "^"ip"/" {print $2}')
cat > /etc/keepalived/keepalived.conf <<EOF
global_defs {
    enable_script_security
    script_user root
}

# Un équilibreur sans HAProxy en marche perd 20 points de priorité : il cède la VIP
vrrp_script verifier_haproxy {
    script "/usr/bin/systemctl is-active --quiet haproxy"
    interval 2
    weight -20
}

vrrp_instance API_K8S {
    state BACKUP
    interface ${IFACE}
    virtual_router_id 51
    priority ${PRIORITE}
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass k8s-ha
    }
    virtual_ipaddress {
        ${VIP}/24
    }
    track_script {
        verifier_haproxy
    }
}
EOF
systemctl enable --now keepalived
systemctl restart keepalived

echo ">>> $(hostname) prêt (priorité ${PRIORITE}, carte ${IFACE})"
