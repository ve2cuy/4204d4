# Lancer, avec Vagrant, une VM docker

*Document converti depuis 4204d4.ve2cuy.com — 24 janvier 2023*

<img src="../../Documentation/images/VM-Docker-avec-Vagrant/Capture-decran-le-2023-01-24-a-13.41.50-1024x571.png" alt="" width="500" />

Fichier Vagrantfile:

```
# -*- mode: ruby -*-
# vi: set ft=ruby :
# ENV['VAGRANT_NO_PARALLEL'] = 'yes'
# --------------------------------------------------------------------
# Fichier:      Vagrantfile
# Version:      1.0
# Auteur:       Alain Boudreault
# Date:         2023.01.24
# Description:  Création d'une VM virtualbox de type Ubuntu srv 20.04,
#               avec installation de docker (docker.io)
#               et des alias pour Docker et K8S
# --------------------------------------------------------------------

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  NodeCount = 1

  (1..NodeCount).each do |i|

    config.vm.define "ubuntuvm#{i}" do |node|
      # La box est cocumentée ici:
      # https://app.vagrantup.com/bento/boxes/ubuntu-20.04ssh
      node.vm.box               = "bento/ubuntu-20.04"
      node.vm.box_check_update  = false
      #node.vm.box_version       = "3.3"
      node.vm.hostname          = "ubuntuvm#{i}.4204d4.cstj"

      node.vm.network "private_network", ip: "192.168.56.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "ubuntu-srv#{i}"
        v.memory  = 4048
        v.cpus    = 4
      end

    end

  end

end
```

Fichier bootstrap.sh:

```
#!/bin/bash

# Enable ssh password authentication
echo "Enable ssh password authentication"
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "Set root password"
echo -e "admin\nadmin" | passwd root >/dev/null 2>&1

# Mise à jour des librairies apt
apt update

# Installation des packages apt
# apt upgrade -y

# Installation de docker
echo "Installation de docker"
apt install docker.io -y

# ======================================================================
# Création des Alias pour le compte root
# ======================================================================

echo "Ajout des Alias pour Docker et K8S dans le fichier /root/.bashrc"
cat <<EOT >> /root/.bashrc
# Voici la liste de mes Alias 'Docker'
# Sous git-bash, à insérer dans le fichier ~/.bashrc
# Sous MacOS, à insérer dans le fichier ~/.zshrc
# -------------------------------------------------------
alias d='docker'
alias dr='docker run'
alias dp='docker container ls'
alias dpp='docker container ls -a'
alias di='docker images'
alias dn='docker network ls'
alias dnc='docker network create'
alias dni='docker network inspect'
alias de='docker exec -it'
alias dv='docker volume ls'
alias dvc='docker volume create'
alias dvi='docker volume inspect'
alias DC='docker-compose'
alias DCd='docker-compose down'
alias DCl='docker-compose logs'

alias dflush='docker container stop $(docker container ls -aq) && docker system prune -af --volumes'
alias dcf='docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)'
alias dif='docker image prune -a -f'
alias dvf=' docker system prune --volumes -f'
alias dinfo='docker system df -v'
alias dsi='docker system info'

# export KUBE_EDITOR='code --wait'

# Alias pour kubectl
alias k='kubectl'

#kubectl logs
alias kl='kubectl logs'

#kubectl apply
alias ka='kubectl apply -f'

# kubectl get
alias kgp='kubectl get pods'
alias kgn='kubectl get nodes'
alias kgd='kubectl get deployment'
alias kgr='kubectl get replicaset'
alias kgs='kubectl get services'
alias kgst='kubectl get secrets'
alias kga='kubectl get all'
alias kgc='kubectl get pods -o=jsonpath="{range .items[*]}{\"\n\"}{.metadata.name}{\":\t\"}{range .spec.containers[*]}{.name}{\", \"}{end}{end}" | sort'
alias kgcm='kubectl get configmaps'

#kubectl create
alias kcd='kubectl create deployment'
alias kcp='kubectl create pod'
alias kcs='kubectl create service'

# kubectl describe
alias kdp='kubectl describe pod'
alias kdps='kubectl describe pods'
alias kdd='kubectl describe deployments'
alias kds='kubectl describe service'
alias kdcm='kubectl describe configmap'

#kubectl delete
alias kdld='kubectl delete deployment'
alias kdlp='kubectl delete pod'
alias kdla='kubectl delete all --all'
alias kdls='kubectl delete service'
alias kdlc='kubectl delete configmaps'

#kubectk edit
alias ked='kubectl edit deployment'

EOT

# ===== FIN du bloc des alias ========================================
```

---

**NOTE**: Ce projet est disponible sur GitHub

```
git clone https://github.com/ve2cuy/vagrant.vm.pour.docker
```
