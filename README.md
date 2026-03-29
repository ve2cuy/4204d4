
# 📚 CSTJ.QC.CA - 420-4D4-JR : Serveurs Internet

*Mise à jour : 16 avril 2021 - Révision 2025.12.04*

## Introduction à Docker et Kubernetes

<p align="center">
    <img src="Documentation/images/k8s.png" alt="" width="200" />
</p>

### Cours préparé par Alain Boudreault

---

## Navigation Rapide

* [Contenus](Documentation/Contenu/)
* [Projet 01](https://github.com/ve2cuy/4204D4-TP01-H26-depart)
* [Épreuve synthèse VH22](https://4204d4.ve2cuy.com/epreuve-synthese-2022/)
* [Copier/coller](Documentation/CopierColler.md)
* [ve2cuy](https://ve2cuy.com/)

---
## Liste des documents de cours

* [Plan de cours - Hiver 2026](Documentation/420-4D4-JR_ab_pc_H26.pdf)
* [Horaire et disponibilités H2026](/Documentation/images/Horaire-H26.png)
* [Calendrier scolaire H26](/Documentation/Contenu/Calendriers_H26_CSTJ.pdf)
* [Description de l'épreuve synthèse - À suivre]()

---

## Évaluation H26
* Projet de mi-session - TP01 sur Docker : **30%**
* Épreuve synthèse volet A - TP02 sur K8s : **35%**
* Épreuve synthèse volet B - Examen pratique - Semaine 16 : **35%**

---

### Concepts et Outils de Base (Docker)

* [01 - Conteneurs vs machines virtuelles](Documentation/Docker/Intro-à-docker-et-kubernetes.md)
* [02 - Installation de Docker](Installation/Docker/Installation-de-Docker.md)
* [03 - Docker – Introduction](Documentation/Docker/Introduction-à-Docker.md)
* [04 - Yaml – Introduction](Documentation/Yaml/yaml.md)
* [05 - Référence Yaml](Documentation/Yaml/yaml-reference.md)
* [06 - Yaml – Exemple d'un document Yaml](Documentation/Yaml/yaml-exemple-ibm.md)
* [07 - hub.docker.com – Introduction](/Documentation/Docker/Docker-Hub.md)
* [08 - Dockerfile – Introduction](Documentation/Docker/Dockerfile-Introduction.md)
* [08b- Dockerfile – Convention de nommage des 'labels'](Documentation/Docker/Dockerfile-convention-de-nommage.md)
* [09 - Dockerfile - Exemple avec une app node.js](Documentation/Docker/Dockerfile-Exemple-node.js.md)
* [F1 - Dockerfile – Formatif 01 - SuperMinou 🐈](Documentation/Docker/Dockerfile-atelier-de-renforcement.md)
* [10 - Docker – Les réseaux](Documentation/Docker/Introduction-aux-réseaux.md)
* [11 - Docker – Application multi-services](Documentation/Docker/Application-multi-services.md)
* [12 - Docker – Retour sur les fusions (bind)](Documentation/Docker/Retour-sur-les-fusions-Bind.md)
* [13a- Docker-Compose – Partie 1](Documentation/Docker/Docker-compose-p1.md)
* * [13b- Docker-Compose – Partie 2](Documentation/Docker/Docker-compose-p2.md)
* * [13c - Docker-Compose – Partie 3](Documentation/Docker/Docker-compose-p3.md)
* [14 - Docker-Compose – Laboratoire (Drupal) TODO:](https://4204d4.ve2cuy.com/docker-compose-laboratoire-drupal/) 🛑
* [15 - Dépôt privé d’images – Harbor](Installation/Registre-privé-d-images.md)
* [16 - Automatisation des builds – GitHub actions](/Documentation/Automatisation/github-action.md)
* [17 - Automatisation des builds – GitHub actions V2](/Documentation/Automatisation/github-action-v2.md)
* [18 - Introduction à Homepage](Documentation/Docker/homepage.md)
* [Docker - Référence rapide](Documentation/Docker/Docker-Référence-rapide.md) 👍
* [Projet de mi-session : 30%](https://github.com/ve2cuy/4204D4-TP01-H26-depart)

### Kubernetes (K8s)

* [20 - Kubernetes – Installation d'un nœud unique sous Linux](Documentation/Kubernetes/Installation-un-seul-noeud.md) 👍
* [21 - Kubernetes – Introduction](Documentation/Kubernetes/Kubernetes-Introduction.md) 👍
* [21b- Kubernetes - kubectl, renforcement](Documentation/Kubernetes/Kubernetes-Introduction-kubectl.md)
* [22 - Kubernetes – Manifestes expliqués - version courte](Documentation/Kubernetes/Kubernetes-Manifestes-Expliques-version-courte.md)
* [23 - Kubernetes – Manifestes expliqués - version longue](Documentation/Kubernetes/Kubernetes-Manisfestes-Expliques-version-longue.md)
* [24 - Kubernetes – Manifestes, Gestion des ressources](Documentation/Kubernetes/Kubernetes-Manifestes-Gestion-des-ressources.md)
* [25 - Kubernetes – Partie 2](Documentation/Kubernetes/Kubernetes-partie-2.md) 👍
* [26 - Kubernetes – Config Map et Secrets](Documentation/Kubernetes/Kubernetes-Config-map-et-secret.md) 👍
* [27 - Kubernetes – Gestion des ressources](Documentation/Kubernetes/Kubernetes-Manifestes-Gestion-des-ressources.md) 👍
* [28 - Préparation à l'atelier d'installation d'un 'cluster' K8s avec Vagrant](https://4204d4.ve2cuy.com/pre-requis-atelier-k8s-vagrant/)
* [29 - Kubernetes – Installation d'un cluster; 1 Master, 2 Nodes](https://4204d4.ve2cuy.com/kubernetes-installation-dun-cluster-1-master-2-nodes/)
* [30 - Kubernetes – Les volumes](Documentation/Kubernetes/Kubernetes-Les-volumes.md) 👍
* [30b-Kubernetes – Les volumes P2](Documentation/Kubernetes/Kubernetes-Volumes-p2.md) 🧠  
* [31 - Kubernetes - Services](Documentation/Kubernetes/Kubernetes-Services.md) 🧠
* [32 - LoadBalancer et ingress avec Traefik](Documentation/Kubernetes/MetalLB-Traefik.md)
* [33 - Kubernetes – LoadBalancer Externe et Ingress avec Nginx - Désuet](Documentation/Kubernetes/Kubernetes-LoadBalancer-et-Ingress.md) 👍
* [34 - Équilibreur de charge externe ML - Info supplémentaire](Documentation/Kubernetes/Equilibreur-de-charge-externe-MetalLB.md) 
* [35 - Espaces de nom (namespaces)]() 🧠
* [36 - ServiceAccount]() 🧠
* [37 - Utilisation d’un cluster sur Google Cloud](Documentation/Kubernetes/Kubernetes-Google.cloud.md) 🧠
* [38 - Helm - Introduction](Documentation/Kubernetes/Helm-introduction.md) 👍
* [39 - Automatisation des ‘builds’ d’images Docker/Github]() 🧠
* [40 - Autoscalling](Documentation/Kubernetes/Kubernetes-autoscalling.md) 👍
* [50 - Épreuve synthèse Volet A : 35 %]
* [51 - Épreuve synthèse Volet B - Examen : 35 %]
* [99 - kubectl - Référence rapide](Documentation/Kubernetes/Kubernetes-Reference-rapide.md) 👍

---

### Outils

* [Les copier/coller](Documentation/CopierColler.md) 👍
* [LazyDocker](https://github.com/jesseduffield/lazydocker)
* [K9s](https://k9scli.io/)
* [Arcane](https://getarcane.app/)
* [Portainer](https://www.portainer.io/)
* [Rancher](https://www.rancher.com/quick-start)
* [LongHorn](https://longhorn.io/)
* [Script d'installation d'un serveur K8s](/Installation/Kubernetes/server.sh)
* [Script d'installation d'un noeud K8s](/Installation/Kubernetes/node.sh)

### Évaluations

* [Énoncé du TP01 – Docker - Version 2023 (30%)](https://4204d4.ve2cuy.com/tp01-docker/)
* [Énoncé du TP02 – K8s – Node-red+mosquitto+configmap+secret (20%)](https://4204d4.ve2cuy.com/tp02-k8s/)
* [Énoncé de l'épreuve synthèse - version 2023 (50%)](https://4204d4.ve2cuy.com/epreuve-synthese-2023/)

---

## Auteur

<img src="Documentation/images/moi.jpg" alt="" width="300" />

- Alain BOUDREAULT
- Enseignant au département de Techniques de l'Informatique
- Cégep de Saint-Jérôme
- Courriel: Aboudrea@cstj.qc.ca
- Téléphone: x6516
- Local: D125e

[Disponibilités pour la session H26](/Documentation/images/Horaire-H26.png)
