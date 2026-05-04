# ESH26 - Énoncé du projet de session

## 💡 Acte d'énoncer, d'exprimer en termes nets.

## 🛑 Version 0.1b - Il y aura des modifications au courant de la semaine!

---

<p align="center">
    <img src="images/superminou.02.png" alt="" width="300" />
</p>

---

## Ce projet comporte deux étapes de réalisation.

* 1️⃣ - Déployer, avec `K8s`, des applications en mode local et les exposer via `HomePage`
  * Toutes les images sont sur un (votre) dépot `Harbor`
  * Certains contenus sont de type `NFS` -> via un service `NFS` sur `cloud.google`
  * Le DNS local est `esh26`
  * Le DNS, pour l'accès aux images est `harbor.matricule.duckdns.org`
  * **REMISE**: `16 mai, 👉 fin de journée`

* 2️⃣ - Déployer, avec `K8s`, des applications en mode `cloud` et les ajouter à `HomePage`
  * Le DNS est `esh26.matricule.duckdns.org`
  * REMISE: `25 mai, 👉 fin de journée`

---

## Étape 1 - Déployer des applications en mode local - `👉 remise le 16 mai`

* À partir d'une VM `cloud.google`
    * Nommée `es-4204d4-h26`
        * e2-small (2 vCPUs, 2 GB Memory) Us-central-1f
        * Disque de 12 GO
        * Sous ubuntu-minimal-2604-resolute-amd64
    * Installer `Harbor` avec certificats `TLS`
        * 👉 Attention au mot de passe
        * 🛑 Ne pas activer le port 80
    * Renseigner un `DNS` sur `DuckDNS` -> `harbor.matricule.duckdns.org`
    * Sous `Harbor`, créer un dépot (projet) nommé `esh26`
        * Placer les images suivantes dans le dépot
            * `homepage:esh26` (à partir de ghcr.io/gethomepage/homepage:latest)
                * **Exemple**: `docker tag ghcr.io/gethomepage/homepage:latest 4204d4.duckdns.org/esh26/homepage:esh26`
                * `docker push 4204d4.duckdns.org/esh26/homepage:esh26`
            * `wordpress:esh26` (à partir de wordpress:latest)
            * `mariadb:esh26` (à partir de mariadb:latest)
            * `jenkins:esh26` (à partir de jenkins/jenkins:lts)    
            * `node-red:esh26` (à partir de nodered/node-red:latest)
            * `mattermost:esh26` (à partir de mattermost/mattermost-preview)
    * Mettre en place un volume `NFS` sur le dossier `/esh26`
        * créer les dossiers `/esh26`, `/esh26/themes`, `/esh26/plugins` et `/esh26/node-red`

* À partir d'un déploiment `k8s` local (soit via VMs ou Docker-Desktop)
    * Installer `metallb`
    * Installer  `traefik` (http://dashbord.esh26)
        * Note: Sous `docker-desktop` il faut utiliser `127.0.0.1 dashboard.esh26 wordpress.esh26 ...` dans `hosts`, sinon, il faut utiliser l'adress IP publique du service `trafik`.
    * Déployer `homepage` 
        * Utiliser l'image du dépot harbor
            * Exemple: `image: 4204d4.duckdns.org/esh26/homepage:esh26`
        * Utiliser des `configMap` (voir les notes de cours) pour les fichiers:
            * `config.yaml`
            * `services.yaml`
            * `widgets.yaml`
            * `bookmarks.yaml`
            * `settings.yaml`
        * Renseigner les liens suivants sous homepage:
            * http://node-red.esh26/
            * http://jenkins.esh26/
            * http://wordpress.esh26/
            * http://mattermost.esh26/
            * https://harbor.matricule.duckdns.org  👉 Accès seulement en `https`!

---

## Captures d'écrans et détails sur les applications

<p align="center">
    <img src="images/superminou.04.png" alt="" width="300" />
</p>

---

## Homepage

<img src="images/homepage.png" alt="" width="800" />

### Détails

* Les fichiers de configuaration sont disponibles via des `configmap` voir [ici](https://ve2cuy.github.io/4204d4/Documentation/Kubernetes/Kubernetes-Config-map-et-secret.html)
* L'image provient du dépôt `harbor` via `harbor.matricule.duckdns.org/esh26/harbor:esh26` 

---

## Wordpress

* Des thèmes supplémentaires proviennent du volune `NFS`  `/esh26/wordpress/themes` voir [ici](https://ve2cuy.github.io/4204d4/Documentation/Kubernetes/Kubernetes-Les-volumes.html)
* Ils doivent-être copiés localement par un conteneur d'initialisation.
* Les thèmes sont disponibles ici (à suivre ...)
* MaraiBD
  * Le volume de `MariaDb` est de type `local-path` voir [ici](https://ve2cuy.github.io/4204d4/Documentation/Kubernetes/Kubernetes-Config-map-et-secret.html)
  * Les informations de connexions doivent-être dans un `secret` voir [ici](https://ve2cuy.github.io/4204d4/Documentation/Kubernetes/Kubernetes-Config-map-et-secret.html)
  
<img src="images/themes-wp.png" alt="" width="800" />

## Contenu NFS des thèmes Wordpress

<img src="images/themes-wp-ls.png" alt="" width="800" />

---

## Node-red

<img src="images/node-red.png" alt="" width="800" />

---

## Contenu NFS de Node-red

* Le dossier /data de node-red est monté sur le volume `NFS` `/esh26/node-red`

<img src="images/node-red-ls.png" alt="" width="800" />

---

## Mattermost

<img src="images/mattermost.png" alt="" width="800" />

---

## Jenkins

* Le volume PVC de jenkins est de type `local-path`

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 5Gi
```

<img src="images/jenkins.png" alt="" width="800" />

---

## 💡 Voici des astuces d'aide à la réalisation du projet

<p align="center">
    <img src="images/superminou.03.png" alt="" width="300" />
</p>


### Certificats pour Harbor

```
# Générer le certificat
sudo certbot certonly --standalone -d 4204d4.duckdns.org

# Renseigner le fichier `harbor.yml`
nano harbor.yml
https:
  # https port for harbor, default is 443
  port: 443
  # The path of cert and key files for nginx
  certificate: /etc/letsencrypt/live/4204d4.duckdns.org/fullchain.pem
  private_key: /etc/letsencrypt/live/4204d4.duckdns.org/privkey.pem

```

---

###  Exemples de PV, PVC à partir d'un volume NFS

Voir [ici](https://ve2cuy.github.io/4204d4/Documentation/Kubernetes/Kubernetes-Les-volumes.html)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-node-red
spec:
  ...
  storageClassName: nfs-node-red
  nfs:
    server: esh26-mon-matricule.duckdns.org
    path: /esh26/node-red

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-node-red
spec:
  storageClassName: nfs-node-red
  ...

```

---

### Renseigner un fichier à partir d'un configMap

```yaml
# ============================================================
# ConfigMap — config.yaml de Homepage
# ============================================================
apiVersion: v1
kind: ConfigMap
metadata:
  name: homepage-config
data:
  config.yaml: |
    title: Homepage
    theme: dark
    color: slate
  
    allowedHosts: homepage.esh26
```

---

### Exemple d'utilisation du dépôt harbor

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: homepage
spec:
  replicas: 1
  selector:
    matchLabels:
      app: homepage
  template:
    metadata:
      labels:
        app: homepage
    spec:
      containers:
      - name: homepage
        image: harbor.matricule.duckdns.org/esh26/homepage:esh26
```


---
---

## Étape 2 - Déployer des applications en nuage - `remise le 25 mai`

<p align="center">
    <img src="images/superminou.05.png" alt="" width="300" />
</p>


👉 À suivre bientôt ...

---