# Installation d'un amas/cluster Kubernetes avec un seul serveur (contrôleur/noeud) sous Ubuntu.

### Étape 1: Préparer le système

**1 – Charger les modules du noyau Linux requis:**

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf 
overlay 
br_netfilter 
EOF
```

**1.1**

```bash
sudo modprobe overlay 
sudo modprobe br_netfilter
```

**2 – Ajuster la configuration réseau requise pour K8S:**

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

**2.1 – Recharger la nouvelle configuration**

```bash
sudo sysctl --system
```

**3 – Installer containerd:**

> **Note**: **Containerd** est un moteur de conteneurs standard de l'industrie qui gère le cycle de vie complet des conteneurs, de la création à la supervision. C'est un projet de la CNCF (Cloud Native Computing Foundation) qui sert de composant clé pour des plateformes comme Docker et est largement utilisé par Kubernetes pour exécuter des conteneurs, grâce à son efficacité et sa robustesse.

```bash
sudo apt-get update
sudo apt-get install -y containerd
```

**4 – Renseigner les droits de groupe requis pour le fonctionnement de containerd:**

```bash
sudo mkdir -p /etc/containerd
# Créer le fichier de configuration
sudo containerd config default | sudo tee /etc/containerd/config.toml
# Ajouter le processus à Cgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
```

**5 – Redémarrer et activer containerd:**

```bash
sudo systemctl restart containerd
# La commande suivante assure que containerd est lancé au redémarrage du serveur
sudo systemctl enable containerd
```

---

### Étape 2: Installer Kubernetes

**6 – Désactiver le fichier d'échange de la mémoire virtuelle:**

```bash
sudo swapoff -a
# Mettre en commentaire l'activation de la mémoire virtuelle de façon permanente.
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Attention, la commande précédente peut ne pas fonctionner si <tab> avant/après 'swap' est utilisé au lieu de ' '!
sudo sed '/\tswap/ s/^\(.*\)$/#\1/g' /etc/fstab
# Ou
sudo sed -i '/swap/ s/^/#/' /etc/fstab

# Dans le doute, tester la command sans -i
# Il est aussi possible d'éditer le fichier manuellement.
```

**7 – Ajouter le dépôt Kubernetes à la commande 'apt':**

```bash
# Pré-requis, obtenir la liste de la dernière version stable disponible pour l'installation:
curl -Ls "https://sbom.k8s.io/$(curl -Ls https://dl.k8s.io/release/stable.txt)/release" | grep "SPDXID: SPDXRef-Package-registry.k8s.io" |  grep -v sha256 | cut -d- -f3- | sed 's/-/\//' | sed 's/-v1/:v1/'
```

👉 Pour obtenir l'historique des versions, c'est [ici](https://kubernetes.io/releases/).

```bash
# Utiliser la version entière pour la variable; 1.34.2 = 1.34
export K8S_VERSION=v1.34
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

> **NOTE**: Initialiser la variable K8S_VERSION par la version désirée

**8 – Installer les applications K8S et bloquer les mises à jours (M-A-J au besoin):**

```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

---

### Étape 3: Réaliser la configuration d'un amas K8s d'un seul noeud (sur le contrôleur)

**9 – Initialiser le contrôleur:**

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16  # --apiserver-advertise-address=a.b.c.d
# L'adresse IP du serveur Linux sera utilisée par défaut comme point d'entrée de gestion au cluster.
```

#### 🤚 Erreur possible

```
W1204 10:58:23.737205    9235 checks.go:827] detected that the sandbox image "registry.k8s.io/pause:3.8"
of the container runtime is inconsistent with that used by kubeadm. 
It is recommended to use "registry.k8s.io/pause:3.10.1" as the CRI sandbox image.
```

**Solution:**

```bash
# Éditer le fichier /etc/containerd/config.toml et corriger la référence:
sandbox_image = "registry.k8s.io/pause:3.8" par
sandbox_image = "registry.k8s.io/pause:3.10.1"
# Redémarrer containerd
```

#### 🤚 Erreur possible

```
[init] Using Kubernetes version: v1.29.15
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR FileContent--proc-sys-net-bridge-bridge-nf-call-iptables]: /proc/sys/net/bridge/bridge-nf-call-iptables does not exist
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```

**Raison**: Étape 1.1 non complétée!

---

**10 – Préparer l'environnement de gestion pour l'utilisateur actuel:**

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

**11- Retirer la contrainte qui empêche le contrôleur de rouler des déploiements localement :**

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

> **NOTE**: Le statut du '**control-plane**' est '**NotReady**' car il manque le service '**C**ontainer **N**etwork **I**nterface'

---

**12 – Installer une couche réseau, utilisée par les déploiements (Flannel CNI plugin):**

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

#--------------------------------------
# namespace/kube-flannel created
# serviceaccount/flannel created
# clusterrole.rbac.authorization.k8s.io/flannel created
# clusterrolebinding.rbac.authorization.k8s.io/flannel created
# configmap/kube-flannel-cfg created
# daemonset.apps/kube-flannel-ds created
```

**13 – Vérifier le fonctionnement de l'amas (cluster K8s):**

```bash
kubectl get nodes
kubectl get pods -n kube-system
```

**Exemple de sortie:**

```
$ kubectl get nodes
NAME      STATUS   ROLES           AGE    VERSION
k8stest   Ready    control-plane   114m   v1.29.15

$ kubectl get pods -n kube-system
NAME                              READY   STATUS    RESTARTS   AGE
coredns-76f75df574-kbl8m          1/1     Running   0          114m
coredns-76f75df574-xqr62          1/1     Running   0          114m
etcd-k8stest                      1/1     Running   0          114m
kube-apiserver-k8stest            1/1     Running   0          114m
kube-controller-manager-k8stest   1/1     Running   0          114m
kube-proxy-j6zbq                  1/1     Running   0          114m
kube-scheduler-k8stest            1/1     Running   0          114m
```

---

## Tester un déploiement

### À partir d'un manifeste disponible via le Web:

```bash
kubectl apply -f https://raw.githubusercontent.com/ve2cuy/4204d4/refs/heads/main/module01/superminou.yml
```

### À partir d'un manifeste local:

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.24.0
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f deployment.yaml

kubectl get pods -o wide

# tester un des serveurs NGINX dans un fureteur local.
# Oui bien, $ curl adresseIPduPod
```

---

## Gestion des erreurs

Si au redémarrage du serveur, kubectl affiche le message suivant:

```bash
alain@kubectl:~$ kubectl get nodes
The connection to the server 192.168.2.155:6443 was refused - did you specify the right host or port?

systemctl status kubelet

# Il faudra afficher le journal de l'application:
journalctl -fu kubelet
```

**Une cause possible:**

```
Nov 01 17:12:10 kubectl kubelet[7023]: E1101 17:12:10.263490    7023 run.go:74] "command failed" err="failed to run Kubelet: running with swap on is not supported, please disable swap! or set --fail-swap-on flag to false. /proc/swaps contained: [Filename\t\t\t\tType\t\tSize\t\tUsed\t\tPriority /swap.img                               file\t\t4009980\t\t0\t\t-2]"
Nov 01 17:12:10 kubectl systemd[1]: kubelet.service: Main process exited, code=exited, status=1/FAILURE
```

La cause ici est le fichier d'échange de la mémoire qui est activé. Il faudra désactiver la mémoire virtuelle.

```bash
sudo swapoff -a
# Ou bien, placer en commentaire la ligne 'swap' du fichier /etc/fstab:
sudo nano /etc/fstab
#/swap.img      none    swap    sw      0       0

# Redémarrer le service kubelet
sudo systemctl start kubelet

# La commande suivante devrait à nouveau fonctionner:
kubectl get nodes

# NAME      STATUS   ROLES           AGE   VERSION
# kubectl   Ready    control-plane   75m   v1.29.15
```

---

## Installation d'un cluster à partir d'un dépôt GitHub


```bash
# Installation d'un contrôleur K8s à partir d'un dépot GitHub
curl https://raw.githubusercontent.com/ve2cuy/4204d4/refs/heads/main/Installation/Kubernetes/server.sh | bash

# Installation d'un noeud K8s à partir d'un dépot GitHub
curl https://raw.githubusercontent.com/ve2cuy/4204d4/refs/heads/main/Installation/Kubernetes/node.sh | bash

# Voici comment changer le rôle d'un noeud
kubectl label node nom-du-noeud node-role.kubernetes.io/worker=worker
```

---

## Mise à jour du cluster

```bash
export K8S_VERSION=v1.34
curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${K8S_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update

sudo apt-mark unhold kubeadm
sudo apt install -y kubeadm='1.34'
sudo apt-mark hold kubeadm

# TODO: compléter la procédure de mise à jour
```

---

## Réinitialiser une installation K8S

```bash
sudo kubeadm reset -f
```

## 🛑 Réinstallation de Docker

Il est possible que Docker ne fonctionne plus suite à l'installation de K8s.

Pour réinstaller, exécuter la commande suivante:

```bash
sudo apt-get install docker.io
```

---

## Installation d'un 'worker Node'

Pour installer un 'worker node' il faut réaliser les étapes 1 à 8 puis,

```bash
# Sur le controleur (control-plane), obtenir la commande pour joindre un noeud au cluster:
sudo kubeadm token create --print-join-command

# Ce qui produit une commande comme:
sudo kubeadm join 192.168.139.50:6443 --token 64th0n.eknzv4kxm1mxwl4o --discovery-token-ca-cert-hash sha256:8ec95c7a7c230d4e1ac11e067ba5a9cd9a0c38c772f500858ac1488c00d065b9

# Exécuter la commande sur le noeud à ajouter à l'amas (cluster)  

```

---

**NOTE**: Voir les alias K8s dans la section [copier/coller](https://4204d4.ve2cuy.com/docker-copier-coller/)

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2026*  
*Version 2025.12.03.1*  
*Site par ve2cuy*