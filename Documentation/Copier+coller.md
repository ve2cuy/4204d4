# Docker copier/coller

*Date: 2 février 2022 - Révision du 2025.12.05*

## 1 – Commandes de base

```bash
# Obtenir le matériel de cours
git clone https://github.com/ve2cuy/4204d4

# - Télécharger et exécuter, avec un lien dossier, un conteneur 
sudo docker run -it -v /Users/alain/Documents/swift/:/alain --name swift swift /bin/bash

# - Créer une image à partir d'un conteneur:
docker commit conteneurID alainboudreault/public:1.0

# - Authentification sur docker hub
sudo docker login --username=

# - Construire un conteneur apache perso
# Dockerfile:
# ---------------------------------------
# FROM httpd:2.4
# COPY ./ve2cuy/ /usr/local/apache2/htdocs/
# ---------------------------------------

sudo docker build -t ve2cuy .

# Construire avec un nom de domaine docker hub et un nom de 'tag'
sudo docker build -t alainboudreault/ve2cuy:depart .

# Publier sur docker hub
sudo docker push alainboudreault/ve2cuy:depart

# Exécuter à partir de docker hub
sudo docker run -dit --name serveur-web-ve2cuy -p 8080:80 alainboudreault/ve2cuy:depart

# --------------------------------------------------------
# Afficher le ID de tous les conteneurs en arrêt 
docker ps -aq
# ou
docker container ls -aq

# --------------------------------------------------------
# Effacer tous les conteneurs en arrêt
docker rm $(docker container ls -aq)
# ou
docker rm $(docker ps -aq)

# --------------------------------------------------------
# Effacer tous les conteneurs et libérer l'espace disque
docker container stop $(docker container ls -aq) && docker system prune -af --volumes

# --------------------------------------------------------
# docker hub login sous Ubuntu 24.04

gpg --generate-key
# fournir le nom du 'USER sous Ubuntu'

pass init 'USER'
# pass init alain

docker login -u dockerhub_user
```

---

## 2 – Voici mes Alias Docker

```bash
# Voici la liste de mes Alias 'Docker'
# Sous git-bash, à insérer dans le fichier ~/.bash_aliases
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
alias w='winpty'

# export KUBE_EDITOR='code --wait'

# Alias pour kubectl
alias k='kubectl'

# kubectl logs
alias kl='kubectl logs'

# kubectl apply
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

# kubectl create
alias kcd='kubectl create deployment'
alias kcp='kubectl create pod'
alias kcs='kubectl create service'

# kubectl describe
alias kdp='kubectl describe pod'
alias kdps='kubectl describe pods'
alias kdd='kubectl describe deployments'
alias kds='kubectl describe service'
alias kdcm='kubectl describe configmap'

# kubectl delete
alias kdld='kubectl delete deployment'
alias kdlp='kubectl delete pod'
alias kdla='kubectl delete all --all'
alias kdls='kubectl delete service'
alias kdlc='kubectl delete configmaps'

# kubectl edit
alias ked='kubectl edit deployment'

# Contextes
alias kcgc='kubectl config get-contexts'
alias kcuc='kubectl config use-context'
# Exemple: $ kubectl config set-context --current --namespace=<namespace>
alias kcsc='kubectl config set-context'
```

---

## 2.1 – Alias en format CMDer

### fichier: %cmder_root%\config\user_aliases.cmd

```cmd
d=docker
dr=docker run
dp=docker container ls
dpp=docker container ls -a
di=docker images
dn=docker network ls
dnc=docker network create
dni=docker network inspect
de=docker exec -it
dv=docker volume ls
dvc=docker volume create
dvi=docker volume inspect
DC=docker-compose
DCd=docker-compose down
DCl=docker-compose logs
dflush=docker container stop $(docker container ls -aq) && docker system prune -af --volumes
dcf=docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)
dif=docker image prune -a -f
dvf=docker system prune --volumes -f
dinfo=docker system df -v
dsi=docker system info
k=kubectl
kl=kubectl logs
ka=kubectl apply -f
kgp=kubectl get pods
kgn=kubectl get nodes
kgd=kubectl get deployment
kgr=kubectl get replicaset
kgs=kubectl get services
kgst=kubectl get secrets
kga=kubectl get all
kgc=kubectl get pods -o=jsonpath="{range .items[*]}{\"\n\"}{.metadata.name}{\":\t\"}{range .spec.containers[*]}{.name}{\", \"}{end}{end}" | sort
kgcm=kubectl get configmaps
kcd=kubectl create deployment
kcp=kubectl create pod
kcs=kubectl create service
kdp=kubectl describe pod
kdps=kubectl describe pods
kdd=kubectl describe deployments
kds=kubectl describe service
kdcm=kubectl describe configmap
kdld=kubectl delete deployment
kdlp=kubectl delete pod
kdla=kubectl delete all --all
kdls=kubectl delete service
kdlc=kubectl delete configmaps
ked=kubectl edit deployment
```

---

## 3 – Augmenter la taille de la police sous Visual Code

```json
Shift+CTRL+P
Choisir: "Open Settings (JSON)"

{
    "terminal.integrated.shell.windows": "C:\\Program Files\\Git\\bin\\bash.exe",
    "terminal.integrated.fontSize": 20,
    "editor.fontSize": 20
}
```

---

## 4 – Cheat Sheet de VS Code

[vscode-keyboard-shortcuts-macos](http://4204d4.ve2cuy.com/wp-content/uploads/2021/03/vscode-keyboard-shortcuts-macos.pdf)

---

## 5 – Les commandes de la semaine

### Semaine 01

```bash
420-4d4.Semaine.01

Concept de conteneurs
    VM vs conteneurs
    Docker
    K8S

Installation
    docker
    mes alias

le CLI de Docker

    $ docker --help
    $ docker commande --help

    $ docker info
    $ docker container ls
    $ docker ps
    $ docker ps -a

    $ d image pull hello-world
    $ d search cowsay

    $ d pull lherrera/cowsay
    $ docker image

    $ docker run hello-world
    $ docker run IMAGE-ID-COWSAY(47) 'Bonjour le monde!'

    $ docker image rm 47 
        Error response from daemon: conflict: unable to delete 47e12946765b (must be forced) - image is being used by stopped container f98b4071e2c3
        $ docker ps -a
        $ docker rm f98
        $ docker image rm 47
        Note: docker rmi -f 47
        
    ---

    $ docker run --name yo alpine (télécharge, exécute et quitte)
    $ docker run -it alpine :  mkdir, touch, vi test, exit
    $ dp, dpp
    $ d restart alpine, dp
    $ d run --name yo -itd alpine
    $ d attach yo, exit, dp
    $ d exec -it alpine /bin/sh, exit, dp
        $ d stop alpine
    $ d rename yo yoyo, dpp    
    $ d rm c9 92 ef ad, dpp

---

    Port IP

    $ docker search nginx
    $ docker pull nginx:latest, di
    $ dr nginx, la console est bloquée par le log du serveur web
        Tester dans un fureteur, pas de résultat
    $ CTRL+C 
    $ d logs CONT_ID 
    $ dr -it -d -p 8080:80 --name web nginx
         Tester dans un fureteur, pas de résultat
    $ d exec -it web bash
        $ nano?, apt install nano, apt update, apt install nano
        Éditer /usr/share/nginx/html/index.html     

---
    Images alainboudreault
    
        $ d  search alainboudreault
        $ dr alainboudreault/bonjour-420
        $ d image inspect alainboudreault/bonjour-420
               --> "Cmd": ["/bin/yo"],
        $ d run -it --name bonjour alainboudreault/bonjour-420 bash
            /# yo
            /# ls
            /# apt install nano
            /# nano bonjour.cpp
            /# gcc bonjour.cpp -o bonjour
            /# mv bonjour /bin/yo
            /# exit
        $ d exec bonjour /bin/yo
        # produire une image avec la nouvelle version
        $ docker commit bonjour bonjour
        $ di
        $ d run bonjour  # l'app bonjour ne roule pas!
        $ d inspect bonjour -> "Cmd": ["bash"]
        $ docker commit --change='CMD ["/bin/yo"]' bonjour:v2
        $ dr bonjour:v2

        Faire labo 3.6 de http://ve2cuy.com/420-4d4b/index.php/docker-introduction/
            Extra, créer une nouvelle image 'image-web' à partir du résultat final et tester.
```

## 6 – Stub docker-compose.yml

```yaml
version: "3.9"
services:
  service01:
    image: 
    container_name: 
    stdin_open: true # docker run -i
    tty: true        # docker run -t

    networks: 
      - reseau01
    environment:
      - VAR01=
      - VAR02=
      
  service02:
    image: 
    container_name: 

    networks: 
      - reseau01
    environment:
      - VAR01=
      - VAR02=    
    command: top      
    volumes: 
    - ./:/420

  service03:
    image: nginx
    container_name: serveurWEB
 
    volumes:
    - ./templates/site.template:/etc/nginx/templates
    - ./contenuweb:/usr/share/nginx/html:rw
 
    ports:
    - "8080:80"
 
    environment:
    - NGINX_HOST=monServeurWeb.com

  maBD:
    image: mariadb
    networks: 
        - reseau02   
    environment:
        - "MYSQL_ROOT_PASSWORD=root"  

  gestionBDviaAppWeb:
    image: adminer
    networks: 
        - reseau02   
    ports:
      - "8081:8080"
    depends_on:
      - maBD

networks:
  reseau01:
    name: jeSuisLeReseau01
    driver: bridge
  reseau02:  
    name: jeSuisLeReseau02
    driver: bridge
```

## 7 – Stub Kubernetes avec un service de type 'LoadBalancer'

```yaml
# Manifeste d'un déploiement avec un service de type LoadBalancer
apiVersion: apps/v1
kind: Deployment
metadata:
  name: un-deployment
  labels:
    app: un-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: un-deployment
  template:
    metadata:
      labels:
        app: un-deployment
    spec:
      containers:
      - name: un-deployment
        image: un-deployment
        ports:
        - containerPort: 80
        env:
        - name: 
          value: 
        - name: 
          value: 
        - name: 
          value:
---
apiVersion: v1
kind: Service
metadata:
  name: nom-du-service
spec:
  selector:
    app: nom_de_app
  type: LoadBalancer  
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 80
      nodePort: 30000
```

---

## 8 – Installation d'un amas K8S (Ubuntu srv 22.04)

```bash
# Désactiver la pagination (swap) du système de fichiers
sudo swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# -------------------------------------------------------------------
# Renseigner le démarrage automatique du moteur d'exécution de Docker
# Note: Il sera installé un peu plus loin dans ce script
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter

# -------------------------------------------------------------------
# Permettre le routage des packets IP entre les noeuds
sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# -------------------------------------------------------------------
# Installer les dép. et le moteur d'exécution de Docker (containerd):
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
# Ajouter le dépôt contenant les packets de containerd
sudo add-apt-repository --yes "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update && sudo apt install -y containerd.io
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
sudo systemctl restart containerd && sudo systemctl enable containerd

# -------------------------------------------------------------------
# Ajouter le dépôt contenant les packets de Kubernetes:
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
sudo apt-add-repository --yes "deb http://apt.kubernetes.io/ kubernetes-xenial main"

# -------------------------------------------------------------------
# Installer les services de K8S - sur tous les noeuds:
sudo apt update && sudo apt install -y kubelet kubeadm kubectl && sudo apt-mark hold kubelet kubeadm kubectl

# -------------------------------------------------------------------
# ===> ****** Exécuter la ligne suivante seulement sur le MASTER:
# Initialiser le cluster K8S
# NOTE: Remplacer par l'adresse IP de la NIC du MASTER
sudo kubeadm init --control-plane-endpoint=192.168.139.50

# -------------------------------------------------------------------
# ===> ****** Exécuter la ligne suivante seulement sur le MASTER:
# Renseigner bash pour l'utilisation de la commande kubectl sur le
# nouveau cluster K8S
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# -------------------------------------------------------------------
# Exécuter la commande suivante sur tous les worker-node:
# Joindre les worker-nodes au cluster K8S:
# Au besoin, obtenir la cmd suivante avec:
# sudo kubeadm token create --print-join-command
sudo kubeadm join 192.168.139.50:6443 --token t0vh7g.x6x0md7uxp6xg33s --discovery-token-ca-cert-hash sha256:26b695e3ea1b7da05fd9d8238d475a62dc697b9dbaaeb1c4ee64808199d02567

# -------------------------------------------------------------------
# ===> ****** Exécuter la ligne suivante seulement sur le MASTER:
# Installer un service réseau pour la communication entre les noeuds:
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml

# -------------------------------------------------------------------
# Pour renommer les noeuds (kubectl get nodes) 
kubectl label node k8s01 node-role.kubernetes.io/control-plane-
kubectl label node k8s01 node-role.kubernetes.io/je-suis-le-boss="true"
kubectl label node k8s02 node-role.kubernetes.io/ouvrier="true"

# -------------------------------------------------------------------
# Renseigner kubectl pour l'utilisation d'un amis distant:
# À partir du master: Obtenir la configuration du cluster:
cat ~/.kube/config > un-cluster-k8s.conf
# Enregistrer la configuration sur le poste de travail et l'utiliser:
export KUBECONFIG=~/un-cluster-k8s.conf
```

---

## 9 – Retirer un noeud d'un amas K8S

```bash
kubectl drain k8s05 --ignore-daemonsets --delete-emptydir-data
kubectl delete node k8s05
```

---

## 10 – Travailler dans un namespace

```bash
# 1 - Renseigner le manifest pour le nouveau NS:
apiVersion: v1
kind: Namespace
metadata:
  name: tp03
  labels:
    name: tp03

---
# 2 - Appliquer le manifest
kubectl apply -f nomduchier.yaml

# 3 - Afficher les NS
kubectl get ns
# NAME                          STATUS   AGE     LABELS
# default                       Active   174d    field.cattle.io/projectId=p-4kp2v,kubernetes.io/metadata.name=default
# ...
# tp03                          Active   31s     kubernetes.io/metadata.name=tp03,name=tp03

# 4 - Ajouter le nouveau context dans le fichier de configuration du kubectl (~/.kube/config):
kubectl config set-context tp03 --namespace=tp03 \       
  --cluster=kubernetes \                  
  --user=kubernetes-admin     

kubectl config view

# Résultat:
# contexts:
# - context:
#     cluster: kubernetes
#     user: kubernetes-admin
#   name: kubernetes-admin@kubernetes
# - context:
#     cluster: kubernetes
#     namespace: tp03
#     user: kubernetes-admin
#   name: tp03

# 5 - Changer de context:
kubectl config use-context tp03 
# Switched to context "tp03".

# 6 - Afficher le context courant:
kubectl config current-context
# tp03

# 7 - Déployer dans le nouveau context
kubectl create deployment un-dep --image=registry.k8s.io/serve_hostname --replicas=3 
kubectl get all

# 8 - Revenir au context par défaut
kubectl config use-context kubernetes-admin@kubernetes

# 9 - Déployer dans un autre context à partir du context courant
kubectl create deployment un-yo -n tp03 --image=registry.k8s.io/serve_hostname

# 10 - Renseigner le context (NS) dans un manifest
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tp03-deployment
  namespace: tp03
  labels:
    app: tp03
spec:
  replicas: 10
  selector:
    matchLabels:
      app: tp03
  template:
    metadata:
      labels:
        app: tp03
    spec:
      containers:
      - name: tp03
        image: alainboudreault/420-4d4-es:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
```

---

## 10.1 – Travailler avec plusieurs contextes

```bash
# Sans modification du fichier ./kube/config
export KUBECONFIG=~/.kube/config:~/.kube/k8s-27.yml:...

# Ou bien, fusionner plusieurs fichiers config en un seul
kubectl config view --flatten > ~/.kube/config-all
# Puis renommer les fichiers

kubectl config set-context prod-context --cluster=prod-cluster --user=admin-user --namespace=production
kubectl config set-context --current --namespace=<namespace>
kubectl config get-contexts
kubectl config use-context <context_name>
kubectl config current-context
```

---

## 11 – Erreur lors du montage d'un volume de type NFS

```bash
# Exemple d'une erreur:
# --> tp03-deployment-c69f588d6-44fm5      0/1     ContainerCreating   0     -->  11h <--

kubectl describe pod tp03-deployment-c69f588d6-44fm5 -n tp03

# Events:
#   Type     Reason       Age                  From     Message
#   ----     ------       ----                 ----     -------
#   Warning  FailedMount  34m (x228 over 11h)  kubelet  Unable to attach or mount volumes: unmounted volumes=[volume-web], unattached volumes=[volume-web kube-api-access-zrshk]: timed out waiting for the condition
#   Warning  FailedMount  19m (x340 over 11h)  kubelet  MountVolume.SetUp failed for volume "pv-nfs-ve2cuy-tp03" : mount failed: exit status 32
# Mounting command: mount
# Mounting arguments: -t nfs ve2cuy.com:/var/nfs/4204D4-tp03 /var/lib/kubelet/pods/19038917-1b36-456f-84b6-97e4b21d3435/volumes/kubernetes.io~nfs/pv-nfs-ve2cuy-tp03
# Output: mount: /var/lib/kubelet/pods/19038917-1b36-456f-84b6-97e4b21d3435/volumes/kubernetes.io~nfs/pv-nfs-ve2cuy-tp03: bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program.
#   Warning  FailedMount  4m53s (x69 over 11h)  kubelet  Unable to attach or mount volumes: unmounted volumes=[volume-web], unattached volumes=[kube-api-access-zrshk volume-web]: timed out waiting for the condition

# ---
# Solution:
# Installer le package nfs-common sur les noeuds du cluster K8S

sudo apt install nfs-common -y

# --> tp03-deployment-c69f588d6-44fm5      1/1     Running             0          11h
```

---

## 12 – J'obtiens une adresse IP externe par service, pourquoi?

```bash
# NAME                        TYPE            CLUSTER-IP       EXTERNAL-IP        PORT(S)          AGE
# service-mariadb-nextcloud   ClusterIP       10.100.231.112   <none>             3306/TCP         11h
# service-mattermost          *LoadBalancer   10.103.65.46     --> 192.168.2.66   8065:30082/TCP   11h
# service-nextcloud           *LoadBalancer   10.107.199.34    --> 192.168.2.65   81:30081/TCP     11h
# tp03-service                *LoadBalancer   10.106.145.154   --> 192.168.2.64   80:30080/TCP     11h
# un-service                  *LoadBalancer   10.107.7.85      --> 192.168.2.63   80:31336/TCP     12h
```

Avec l'utilisation d'un load balancer externe, comme metallb, il faut renseigner des règles ingress si vous voulez proposer une seule porte d'entrée au cluster K8S.

De plus, le `type:` du service doit être égal à `ClusterIP`. S'il est égal à `LoadBalancer`, alors une adresse externe unique sera attribuée au service.

```yaml
# Par exemple, cet exemple va consommer une adresse externe unique:
apiVersion: v1
kind: Service
metadata:
  name: service-mattermost
spec:
  selector:
    app: mattermost
  type: LoadBalancer # <-- Si non renseigné, alors sera égal à ClusterIP et fonctionnera avec le 'ingress controler'.
  ports:
    - name: http
      protocol: TCP
      port: 80          # Port à exposer
      targetPort: 8065  # Port du conteneur
```

---

## 13 – Fixer l'éditeur pour la commande kubectl edit

```bash
export KUBE_EDITOR="code --wait"
```

---

## 14 – K8S : Commandes utiles

```bash
# Afficher les pods en exécution:
kubectl get pods --field-selector status.phase=Running

# Modifier le nombre d'instances d'une app
kubectl scale deployment deploy-superminou --replicas=5

# Exposer le port d'un pod
```

---

## 15 – Outils

* [Portainer](https://www.portainer.io/)

```bash
docker run -d -p 8000:8000 -p 9000:9000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest
```

* [Rancher](https://www.rancher.com/)

```bash
sudo docker run --privileged -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher
```

* [Longhorn](https://longhorn.io/)
* [Charts | Helm](https://helm.sh/docs/topics/charts/)
* [K9s](https://k9scli.io/)

<img src="../images/Capture-decran-2025-12-02-114632-1024x773.png" alt="K9s Interface" width="500" />

```bash
# Utiliser : pour soumettre des commandes supplémentaires ou sélectionner des ressources. Par exemple:
:deploy
:pv
:secret
:q!
```

---

## 16 – Importer un cluster dans portainer (sans LB)

<img src="../images/Capture-decran-2025-12-01-112824-858x1024.png" alt="Portainer Cluster Import" width="500" />

---

## 50 – Scripts bash de création de Master/Worker sur Ubuntu 24.04

**Note**: Si vous avez cloné des VM, ne pas oublier de mettre à jour les fichiers `/etc/hosts` et `/etc/hostname` avant de rouler les scripts suivants.

**Syntaxe**:

```bash
sudo bash script.sh
```

**ATTENTION, ERREUR POSSIBLE sur weave**

```bash
kubectl get pods --all-namespaces -o wide -w

# NAMESPACE     NAME                               READY   STATUS              RESTARTS        AGE   IP                NODE       NOMINATED NODE   READINESS GATES
# default       nginx-deployment-69b84fcc8-5qknt   0/1     ContainerCreating   0               12m   <none>            k8snode1   <none>           <none>
# default       nginx-deployment-69b84fcc8-tvmsg   0/1     ContainerCreating   0               12m   <none>            k8snode2   <none>           <none>
# ...
# kube-system   weave-net-2zg52                    1/2     CrashLoopBackOff    7 (4m43s ago)   15m   192.168.188.136   k8snode2   <none>           <none>
# kube-system   weave-net-tqlt8                    1/2     CrashLoopBackOff    16 (3m5s ago)   59m   192.168.188.133   4204d4     <none>           <none>
# kube-system   weave-net-zdk7l                    1/2     CrashLoopBackOff    11 (2m1s ago)   33m   192.168.188.135

# Solution, réinstaller la version la plus récente (sur le master)
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml

kubectl get pods --all-namespaces -o wide -w

# NAMESPACE     NAME                               READY   STATUS    RESTARTS      AGE   IP                NODE       NOMINATED NODE   READINESS GATES
# default       nginx-deployment-69b84fcc8-5qknt   1/1     Running   0             24m   10.40.0.0         k8snode1   <none>           <none>
# default       nginx-deployment-69b84fcc8-tvmsg   1/1     Running   0             24m   10.32.0.1         k8snode2   <none>           <none>
# ...
# kube-system   weave-net-hjqtw                    2/2     Running   1 (15s ago)   18s   192.168.188.136   k8snode2   <none>           <none>
# kube-system   weave-net-hws22                    2/2     Running   1 (16s ago)   18s   192.168.188.135   k8snode1   <none>           <none>
# kube-system   weave-net-q9pfj                    2/2     Running   1 (15s ago)   18s   192.168.188.133   4204d4     <none>           <none>
```

### 50.1 – Pour le master

Le script pour le master est trop long pour être affiché ici. Référez-vous au document original pour le contenu complet du script master.

### 50.2 – Pour les workers

Le script pour les workers est également trop long pour être affiché ici. Référez-vous au document original pour le contenu complet du script worker.

---