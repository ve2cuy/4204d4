# ESH26 - Énoncé du projet de session

### 💡 Acte d'énoncer, d'exprimer en termes nets.
---

<p align="center">
    <img src="superminou.02.png" alt="" width="300" />
</p>

---

Ce projet comporte deux étapes de réalisation.

* 1 - Déploiyer, avec K8s, des applications en mode local et les exposer via HomePage
  * Toutes les images sont sur un dépot via Harbor
  * Certains contenus sont de type NFS -> via un serveur NFS sur cloud.google
  * Le DNS local = esh26.4204d4
  * Le DNS, pour l'accès aux images = depot.matricule.duckdns.org
  * REMISE: 16 mai, fin de journée
* 2 - Déploiyer, avec K8s, des applications en mode `cloud` et les ajouter à HomePage
  * Le DNS = esh26.matricule.duckdns.org
  * REMISE: 25 mai, fin de journée

---

## Étape 1 - Déploiyer des applications en mode local (remise 16 mai)

* À partir d'une VM cloud.google
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
            * homepage:esh26 (à partir de ghcr.io/gethomepage/homepage:latest)
            * Wordpress:esh26 (à partir de wordpress:latest)
            * mariadb:esh26 (à partir de mariadb:latest)
            * jenkins:esh26 (à partir de jenkins/jenkins:lts)    
            * node-red:esh26 (à partir de nodered/node-red:latest)
            * mattermost:esh26 (à partir de mattermost/mattermost-preview)
    * Mettre en place un volume NFS sur le dossier `/esh26`
        * créer les dossiers `/esh26`, `/esh26/themes`, `/esh26/plugins` et `/esh26/node-red`

* À partir d'un déploiment k8s local (soit via VMs ou Docker-Desktop)
    * Installer `metallb`
    * Installer  `traefik` (http://dashbord.esh26)
        * Note: Sous `docker-desktop` il faut utiliser `127.0.0.1 dashboard.esh26 wordpress.esh26 ...` dans `hosts`, sinon, il faut utiliser l'adress IP publique du service Trafik.
    * Déployer `homepage` 
        * Utiliser des `configMap` (voir les notes de cours) pour les fichiers:
            * config.yaml
            * services.yaml
            * widgets.yaml
            * bookmarks.yaml
            * settings.yaml 
        * Renseigner les liens suivants sous homepage:
            * http://node-red.esh26/
            * http://jenkins.esh26/
            * http://wordpress.esh26/
            * http://mattermost.esh26/
            * https://harbor.matricule.duckdns.org



---

## Étape 2 - Déploiyer des applications en nuage (remise 25 mai)

👉 À suivre ...

---
