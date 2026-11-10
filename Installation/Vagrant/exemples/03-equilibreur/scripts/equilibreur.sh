#!/bin/bash
# Équilibreur de charge : HAProxy, en tourniquet (round robin) sur les serveurs Web
# Variable reçue du Vagrantfile : SERVEURS="web1:192.168.56.31 web2:192.168.56.32"
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

rm -f /etc/netplan/01-netcfg.yaml   # défaut de la boîte : document 33, section 9.5

apt-get update -q
apt-get install -y -q haproxy

{
  cat <<'FIN'
global
    log /dev/log local0

defaults
    mode    http
    timeout connect 5s
    timeout client  30s
    timeout server  30s

frontend site
    bind *:80
    default_backend serveurs_web

frontend statistiques
    bind *:8404
    stats enable
    stats uri /
    stats refresh 5s

backend serveurs_web
    balance roundrobin
    option httpchk GET /
FIN
  for s in ${SERVEURS}; do
    echo "    server ${s%%:*} ${s#*:}:80 check inter 2s"
  done
} > /etc/haproxy/haproxy.cfg

haproxy -c -f /etc/haproxy/haproxy.cfg
systemctl restart haproxy
echo ">>> Équilibreur prêt : http://localhost:8080 et http://localhost:8404"
