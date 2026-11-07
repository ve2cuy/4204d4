# Kubernetes – Installation

*Document converti depuis 4204d4.ve2cuy.com — 7 avril 2021*

<img src="../images/Kubernetes-Installation-cluster/installation-k8s-sur-vm.png" alt="" width="500" />

## Contenu

* **Mise en situation**
* **Création de machines virtuelles avec *Vagrant***
  * Démarrer les VM – *vagrant up*
  * Se connecter aux VM – *vagrant ssh*
  * Désactiver la partition d’échanges
  * Installer *docker*
  * Établir un pond entre les réseaux
  * Activer le DNS local
* **Installer les applications K8s sur les noeuds – sous Ubuntu SRV 20.04**
  * Installer la *clé gpg* et le dépôt *apt-get* de Google
  * Installer les packages: *kubelet*, *kubeadm* et *kubectl*
* **Initialiser le noeud maître (master node)**
* **Joindre les noeuds ouvriers (worker node) au cluster K8s**
* **Ajustements et tests**

**Note**: Une version plus récente des étapes (sous Ubuntu 22.04) est disponible au bas de ce document.

---

### Mise en situation

À date, nous avons fait nos apprentissages de *Kubernetes* en utilisant le ‘*cluster K8s*‘ proposé par *minikube*.

Étant donné que, peu importe le type d’installation *K8s*, nous utilisons habituellement l’application ‘*cli kubectl*‘ pour gérer le ‘*cluster*‘, cela n’a pas été un frein à nos expérimentations.

Par contre, en entreprise, il est peu probable qu’on vous demande de mettre en place une infrastructure *K8s* avec *minikube*.

Voici donc comment déployer une infrastructure *Kubernetes* sur des serveurs Linux.

Dans ce laboratoire, nous installerons un noeud maître (*control-plane,master*) et deux (2) noeuds ouvriers (*worker node*).

---

### 1 – Mise en place des VM (avec vagrant)

Pour notre réseau K8s, nous allons mettre en place trois serveurs Linux grace à l’utilisation de machines virtuelles;

* 1 Master
* 2 Worker node

Dans le but de simplifier la création et l’installation de Linux sur les VM, nous allons utiliser l’outil ‘*Vagrant*‘ qui, à partir d’un fichier de directives, va réaliser toutes les opérations de l’installation automatiquement.

Voici le fichier *Vagrantfile*:

```
# -*- mode: ruby -*-
# vi: set ft=ruby :
# =========================================================================
# Nom du fichier:     Vagrantfile
# Auteur:             Alain Boudreault
# Date:               2021.04.07
# -------------------------------------------------------------------------
# M-A-J: 2021.04.15 - Ajout du routage des paquets IP et du DNS local
# -------------------------------------------------------------------------
# Démarrage:          vagrant up
# Lister les VM:      vagrant global-status
# Login via vagrant:  vagrant ssh nomDeLaMachine
#   Pour passer en mode root: sudo -s pour passer en root
#   Pour permettre ssh:       sudo passwd vagrant
#
# Login direct:       ssh vagrant@ip (password=vagrant)
# Arrêt des VM:       vagrant halt
# Suppression des VM: vagrant destroy
# =========================================================================
# https://raw.githubusercontent.com/ve2cuy/4204d4/main/module06/Vagrantfile
# ---------------
# Voici un exemple K8s complet: https://github.com/ansilh/k8s-vagrant
# =========================================================================

Vagrant.configure("2") do |config|
  # master server
  config.vm.define "k8s-master" do |kmaster|
    kmaster.vm.synced_folder '.', '/vagrant', disabled: true
    kmaster.vm.box = "ubuntu/focal64"
    kmaster.vm.hostname = "k8s-master"
    # Installer docker sur la VM
    kmaster.vm.provision "docker"
    kmaster.vm.box_url = "ubuntu/focal64"
    kmaster.vm.network :private_network, ip: "192.168.56.101"
    kmaster.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ["modifyvm", :id, "--name", "k8s-master"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
    end
    # Activation du ssh hors vagrant:
    config.vm.provision "shell", inline: <<-SHELL
      sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
      service ssh restart
      # Activer le routage des paquets IP entre les réseaux
      echo "[SCRIPT][INFO] Activer le routage des paquets IP entre les réseaux:"
      sysctl -w net.ipv4.ip_forward=1
      sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
      echo "[SCRIPT][INFO] Activer la résolution DNS pour les applications locales"
      systemctl enable systemd-resolved.service
      systemctl start  systemd-resolved.service
    SHELL
  end

  numberSrv=2
  # slave server
  (1..numberSrv).each do |i|
    config.vm.define "k8s-node#{i}" do |knode|
      knode.vm.synced_folder '.', '/vagrant', disabled: true
      knode.vm.box = "ubuntu/focal64"
      knode.vm.hostname = "k8s-node#{i}"
      # Installer docker sur la VM
      knode.vm.provision "docker"
      knode.vm.network "private_network", ip: "192.168.56.10#{i+1}"
      knode.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        v.name = "k8s-node#{i}"
        v.memory = 1024
        v.cpus = 1
      end
      # Activation du ssh hors vagrant:
     config.vm.provision "shell", inline: <<-SHELL
       sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config
       service ssh restart
      # Activer le routage des paquets IP entre les réseaux
      echo "[SCRIPT][INFO] Activer le routage des paquets IP entre les réseaux:"
      sysctl -w net.ipv4.ip_forward=1
      sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
      echo "[SCRIPT][INFO] Activer la résolution DNS pour les applications locales"
      systemctl enable systemd-resolved.service
      systemctl start  systemd-resolved.service
     SHELL
    end
  end
end
```

**NOTE**: Il est possible d’obtenir la version la plus récente de ce Vagrantfile ainsi:

```
wget https://raw.githubusercontent.com/ve2cuy/4204d4/main/module06/Vagrantfile

# Ou

curl https://raw.githubusercontent.com/ve2cuy/4204d4/main/module06/Vagrantfile > Vagrantfile
```

### 1.1 – Lancer le script vagrant:

Cette opération va créer trois (3) VM Linux.

```
# Dans le dossier où se trouve le fichier Vagrantfile:

$ vagrant up

# Note: La première fois, vagrant devra télécharger
# les Box (images de machines virtuelles), ce qui peut prendre du temps.

# Si vous avez déjà la Box, il est possible d'obtenir la version la plus
# récente avec cette commande:

$ vagrant box update
```

**Note:** Pour ceux et celles qui aimeraient en apprendre davantage sur vagrant, la documentation de son *‘cli’* est [ici](https://www.vagrantup.com/docs/cli).

---

### 1.2 – Installer docker sur les noeuds

```
L'installation de Docker est dans le fichier Vagrantfile
```

---

### 1.3 – Désactiver le fichier d’échanges (swap)

Kubernetes ne fonctionne pas sur des serveurs pour lesquels la mémoire virtuelle (swap file/partition) est activée.

Il faut vérifier les volumes du serveur et au besoin, désactiver la partition d’échange (swap partition).

```
# Connexion au master de Kubernetes
vagrant ssh k8s-master

# Afficher les partitions des disques:
# Vérifier s'il y a une partition d'échanges 'swap';
df -hv

# Au besoin, désactiver la partition 'swap'
# Passer en mode root
sudo -s
# Désactiver la partition 'swap' pour la session en cours
swapoff -a

# Renseigner le système pour que le 'swap' soit désactivé à chaque redémarrage
# Au besoin, commenter la ligne de 'swap'.
nano /etc/fstab

# Vérifier que le fichier d'échanges est bien désactivé;

df -hv
```

---

### 1.4 – Au besoin, installer curl et apt-transport-https

```
apt install curl apt-transport-https
```

**Note**: Pour la Vagrant Box ‘*ubuntu/focal64*‘ ces deux applications sont déjà installées.

---

### 1.5 – Installer la clé gpg et le dépôt apt-get de Google

Pour être en mesure d’installer les applications nécessaires au fonctionnement de K8s, il faut ajouter la clé des packages Google – qui est l’éditeur de l’application *Kubernetes* – et ajouter l’adresse du dépôt dans la configuration de *apt-get*.

```
# Ajout de la clé
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Ajout du dépôt
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
```

**** NOTE IMPORTANTE**: ** Il faut ajuster le nom du ‘package k8s’ en fonction de la distribution de Linux utilisée.  Par exemple, pour Ubuntu 20.04 le nom du ‘package’ est ‘[kubernetes-focal](https://wiki.ubuntu.com/Releases)‘.  Par contre, au moment d’écrire ce document, Google n’a pas encore [publié de package pour ‘focal’](https://packages.cloud.google.com/apt/dists). Nous allons alors nous rabattre sur la version ‘xenial’

### 1.6 – Actualiser le système et installer les modules Kubernetes

```
sudo apt-get update

apt-get install -y kubelet kubeadm kubectl
```

Ceci termine l’installation des pré-requis

---

**Note**: **Si un pare-feu est installé**, il faudra ouvrir les ports suivants:

```
# Vérifier si le pare-feu est actif:
ufw status

# Ouverture de ports sur le master:
sudo ufw allow 6443/tcp
sudo ufw allow 2379/tcp
sudo ufw allow 2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10251/tcp
sudo ufw allow 10252/tcp
sudo ufw allow 10255/tcp
sudo ufw reload

# Ouverture de ports sur les nodes:
sudo ufw allow 10251/tcp
sudo ufw allow 10255/tcp
sudo ufw reload
```

---

### 2 – Initialiser l’infrastructure du ‘cluster’ K8s

**Étapes:**

1. **Initialiser le noeud maître (master node).**
2. **Installer un service réseau intra-noeuds**
3. **Permettre au noeud maître de rouler des Pods**
4. **Joindre les noeuds ouvriers (worker node) à l’infrastructure.**

---

**2.1 –** **Étape 1 – initialiser le noeud maître**

```
kubeadm init --apiserver-advertise-address=192.168.56.101 --node-name $HOSTNAME --pod-network-cidr=10.244.0.0/16

# ATTENTION: Il sera peut-être nécessaire d'ajuster l'adresse IP du serveur.  Confirmer avec 'ip a':

3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:9d:c0:ed brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.101/24 brd 192.168.56.255 scope global enp0s8
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe9d:c0ed/64 scope link
       valid_lft forever preferred_lft forever

------
Ce qui produira:

[init] Using Kubernetes version: v1.20.5
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
        [WARNING SystemVerification]: this Docker version is not on the list of validated versions: 20.10.5. Latest validated version: 19.03
        [WARNING SystemVerification]: missing optional cgroups: hugetlb
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.56.101]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.56.101 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [192.168.56.101 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
```

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.100.10:6443 --token 0wmo0n.bzxzltx2coxg8hyf \
    --discovery-token-ca-cert-hash sha256:da332b0aa033dac51112da2ce63d58fde8f582359658568372e95ca2d9be5081
```

---

**** NOTE IMPORTANTE: **** **Le message précédent affiche la commande à utiliser, sur les noeuds, pour les joindre au ‘cluster’**.  ***Le jeton de connexion est valide pour 24 heures** ->* **il est possible de le ré-actualiser avec:**

```
sudo kubeadm token create --print-join-command
```

**NOTE**: En cas de problème avec kubeadm, voir [ici](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/troubleshooting-kubeadm/).

---

Corriger le message d’avertissement suivant:

```
[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd".

Please follow the guide at https://kubernetes.io/docs/setup/cri/
```

```
# Étape 1
$ sudo nano /etc/docker/daemon.json et ajouter

{
   "exec-opts": ["native.cgroupdriver=systemd"],
   "log-driver": "json-file",
   "log-opts": {
     "max-size": "100m"
   },
   "storage-driver": "overlay2"
 }

---

# Étape 2
sudo nano /etc/sysctl.conf

et décommenter la ligne

#net.ipv4.ip_forward=1

# Étape 3
redémarrer le master
```

**Note:** Pour tout remettre à zéro (danger): ***kubeadm reset***

---

**2.2 –** Afficher les noeuds disponibles dans le ‘cluster’ K8s :

**2.2.1 –** Comme root:

```
root@k8s-master:/home/vagrant# export KUBECONFIG=/etc/kubernetes/admin.conf

root@k8s-master:/home/vagrant# kubectl get nodes
NAME         STATUS     ROLES                  AGE     VERSION
k8s-master   NotReady   control-plane,master   2m53s   v1.20.5
```

**2.2.2 –** Comme utilisateur:

```
# Note: À faire, une seule fois, sur le master:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

---

kubectl get nodes
```

**Note:** Le ‘STATUS’ du master est ‘**NotReady**‘.  Il reste à installer un service réseau.

---

**2.3 –** **Étape 2 – installer un service réseau pour l’infrastructure K8s.**

```
# Il y a plusieurs services réseaux disponibles pour K8s, en voici deux:

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Ou bien:

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

-----
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created
```

**2.3.1 –** Vérifier l’état du Pod flannel (cni):

```
kubectl get pods -n kube-system

---

NAME                                 READY   STATUS    RESTARTS   AGE
kube-flannel-ds-bw7d8                1/1     Running   3          79m
kube-flannel-ds-f5t9g                1/1     Running   3          79m
```

---

**2.3.2 –** Programmer le ‘routage’ des paquets IP entre les différents réseaux et de la résolution de noms pour les applications locales.

Ceci est nécessaire pour permettre la communication entre le réseau du host et le réseau des Pods.

**NOTE:** C’est déjà fait dans le Vagrantfile donc, **ne pas exécuter** les commandes suivantes!  **Fun fact**, si jamais vous *outrepassez* cette directive, rien ne sera ‘brisé’, ce sera seulement une perte de temps pour vous **;)-**.

```
# Activer la redirection de paquets IP V4:
sudo nano /etc/sysctl.conf

# Uncomment the next line to enable packet forwarding for IPv4
net.ipv4.ip_forward=1

---

# Activer la résolution DNS pour les applications locales"
systemctl enable systemd-resolved.service
systemctl start  systemd-resolved.service
```

---

**2.4 –** Afficher les noeuds disponibles :

```
kubectl get nodes
NAME         STATUS   ROLES                  AGE   VERSION
k8s-master   Ready    control-plane,master   13m   v1.20.5

kubectl get services
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   13m
```

Note: Le ‘STATUS’ du master est ‘**Ready**‘.

---

### 3 – Permettre au noeud maître de rouler des Pods

Pour des raisons de sécurité, K8s ne déploie pas de Pods sur le Master.  Par contre, est possible d’activer cette fonction avec la commande suivante:

```
kubectl taint nodes --all node-role.kubernetes.io/master-
```

---

### 4 – Joindre un noeud ouvrier au ‘cluster’ K8s

Nous allons maintenant joindre le ou les noeuds à l’infrastructure Kubernetes.

À la fin de l’initialisation du noeud maître, la commande à utiliser pour joindre les noeuds au ‘cluster’ a été affichée à l’écran.

Cette commande inclue une clé qui est valide pendant 24 heures (cela pourrait changer avec une nouvelle version de K8s).

Passé ce délai, il est possible de générer une nouvelle clé comme ceci:

```
sudo kubeadm token create --print-join-command
```

**4.0 –** Joindre *k8s-node1* à l’infrastructure K8s:

```
Sur le noeud k8s-node1:

kubeadm join 192.168.100.10:6443 --token 1mijl8.4ltfiinf0rc7e9rf --discovery-token-ca-cert-hash sha256:c7972526ba9d4e66e303b17b947b0777fbf3564abf2c30efebbd2c88efff86d9
```

**4.1 –** Vérifier la disponibilité des noeuds:

```
 kubectl get nodes
NAME         STATUS   ROLES                  AGE     VERSION
k8s-master   Ready    control-plane,master   44m     v1.21.0
k8s-node1    Ready    <none>                 4m36s   v1.21.0
```

**4.2 –** Modifier le rôle d’un noeud:

```
kubectl label node k8s-node1 node-role.kubernetes.io/worker=worker

---
kubectl get nodes

kubectl get nodes
NAME         STATUS   ROLES                  AGE   VERSION
k8s-master   Ready    control-plane,master   53m   v1.21.0
k8s-node1    Ready    worker                 13m   v1.21.0

# kubectl edit node k8s-node1
```

**4.3 –** Au besoin, répéter les opérations sur les autres noeuds ouvriers.

---

### 5 – Erreurs possibles avec Vagrant et VirtualBox

*La création d’une **VM** avec ‘vagrant’ donnera une machine avec **2 CIR**; un réseau NAT et un réseau privé.*

*Par défaut, ‘kubelet‘ utilisera la première CIR, ce qui provoquera une malfunction du système.*

**Symptôme**:

**kubectl run id_du_pod  –image=nginx**

**kubectl exec -it id_du_pod — bash**

*error: unable to upgrade connection: pod does not exist*

**Solution**:

Modifier le fichier de configuration ‘*kubelet*‘ des noeuds ouvriers.

**5.1 –** Identifier l’adresse IP du réseau privé du noeud:

```
$ root@k8s-node1:/home/vagrant# ip a
---
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:ce:18:ba brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.102/24 brd 192.168.56.255 scope global enp0s8
```

**5.2 –**Éditer le fichier de configuration de *kubelet* du noeud:

```
root@k8s-node1: # nano /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
---
# Ajouter cette ligne au fichier:

   Environment="KUBELET_EXTRA_ARGS=--node-ip=*.*.*.*"
   *.*.*.* = Adresse IP de la CIR du réseau privé du noeud,
   Par exemple,

   Environment="KUBELET_EXTRA_ARGS=--node-ip=192.168.56.102"
---

sudo systemctl daemon-reload
sudo systemctl restart kubelet

---
# Valider avec:

kubectl get nodes -o wide

NAME         STATUS   ROLES                  AGE    VERSION   INTERNAL-IP      EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
k8s-master   Ready    control-plane,master   161m   v1.21.0   10.0.2.15        <none>        Ubuntu 20.04.2 LTS   5.4.0-71-generic   docker://20.10.6
k8s-node1    Ready    worker                 121m   v1.21.0   192.168.56.102   <none>        Ubuntu 20.04.2 LTS   5.4.0-71-generic   docker://20.10.6
```

**ATTENTION**, Il **ne faut pas** faire cette modification sur le noeud maître sinon, il n’**aura plus accès** à Internet via le réseau **NAT**.  Il ne sera donc plus en mesure de télécharger les images de hub.docker.io.

Voilà, le commande ‘*kubectl exec -it*‘ devrait maintenant fonctionner 😉

---

### 6 – Tester l’infrastructure K8s

```
kubectl create deployment webserver --image=nginx --port 80 --replicas=5

# La prochaine commande permet de vérifier l'exactitude des adresses IP
kubectl exec -it nom-du-pod -- bash

kubectl expose deployment webserver --port 80 --type=NodePort

kubectl get pods

kubectl scale deploy webserver --replicas=5
```

---

En cas de problème avec le *cluster*, il est possible d’afficher le journal de *kubelet*:

```
sudo journalctl -u kubelet | tail -n 100
```

---

### 7 – Programmer la complétion de code pour *kubectl* sur le master

```
nano ~/.profile

# Ajouter ceci à la fin du fichier:

source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k
```

---

### Conclusion

Voilà, nous avons installé un ‘cluster’ *Kubernetes*, composé d’un ‘*master*‘ et de, deux (2) ‘*nodes*‘.

Il ne manque qu’un équilibreur de charge, un point de service, pour les requêtes, par exemple, de type *HTTP*.

Pour cela, il faudra mettre en place ‘[*Ingress*](https://kubernetes.io/fr/docs/concepts/services-networking/ingress/)‘

---

**NOTE – Il faut penser à arrêter les VM via vagrant:**

```
vagrant halt

# Pour redémarrer les VM
vagrant up

# Pour détruire les VM
vagrant destroy
```

Effacer les CIR VirtualBox

```
VBoxManage hostonlyif remove vboxnet0
```

---

## Installation rapide de K8S sous Ubuntu 22.04

```
# 1 - Désactiver la pagination (swap) du système de fichiers
sudo swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# -------------------------------------------------------------------
# 2 - Renseigner le démarrage automatique du moteur d'exécution de Docker
# Note: Il sera installé un peu plus loin dans ce script
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter

# -------------------------------------------------------------------
# 3 - Permettre le routage des packets IP entre les noeuds
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# -------------------------------------------------------------------
# 4 - Installer les dép. et le moteur d'exécution de Docker (containerd):
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
# Ajouter le dépôt contenant les packets de containerd
sudo add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update && sudo apt install -y containerd.io
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd && sudo systemctl enable containerd

# -------------------------------------------------------------------
# 5 - Ajouter le dépôt contenant les packets de Kubernetes:
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
sudo apt-add-repository --yes "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# -------------------------------------------------------------------
# 6 - Installer les services de K8S - sur tous les noeuds:
sudo apt update && sudo apt install -y kubelet kubeadm kubectl && sudo apt-mark hold kubelet kubeadm kubectl

# -------------------------------------------------------------------
# ===> ****** Exécuter la ligne suivante seulement sur le MASTER:
# 7 - Initialiser le cluster K8S
# NOTE: Remplacer par l'adresse IP de la NIC du MASTER
sudo kubeadm init --control-plane-endpoint=192.168.139.50

# -------------------------------------------------------------------
# ===> ****** Exécuter la ligne suivante seulement sur le MASTER:
# 8 - Renseigner bash pour l'utilisation de la commande kubectl sur le
# nouveau cluster K8S
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# -------------------------------------------------------------------
# 9 - Exécuter la commande suivante sur tous les worker-node:
# Joindre les worker-nodes au cluster K8S:
# Au besoin, obtenir la cmd suivante avec:
# sudo kubeadm token create --print-join-command
sudo kubeadm join 192.168.139.50:6443 --token t0vh7g.x6x0md7uxp6xg33s --discovery-token-ca-cert-hash sha256:26b695e3ea1b7da05fd9d8238d475a62dc697b9dbaaeb1c4ee64808199d02567

# -------------------------------------------------------------------
# ===> ****** Exécuter la ligne suivante seulement sur le MASTER:
# 10 - Installer un service réseau pour la communication entre les noeuds:
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# -------------------------------------------------------------------
# 11- Pour renommer les noeuds (kubectl get nodes)
kubectl label node k8s01 node-role.kubernetes.io/control-plane-
kubectl label node k8s01 node-role.kubernetes.io/je-suis-le-boss="true"
kubectl label node k8s02 node-role.kubernetes.io/ouvrier="true"

# -------------------------------------------------------------------
# 12 - Renseigner kubectl pour l'utilisation d'un amas distant:
# À partir du master: Obtenir la configuration du cluster:
cat ~/.kube/config > un-cluster-k8s.conf
# Enregistrer la configuration sur le poste de travail et l'utiliser:
export KUBECONFIG=~/un-cluster-k8s.conf
```

---

###### Document rédigé par Alain Boudreault – aka, ve2cuy – version 2023.04.06.01
