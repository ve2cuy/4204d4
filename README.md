
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
* [Épreuve synthèse VH22](https://4204d4.ve2cuy.com/epreuve-synthese-2022/)
* [Copier/coller](Documentation/CopierColler.md)
* [ve2cuy](https://ve2cuy.com/)

---
## Liste des documents de cours

* [Plan de cours - À suivre]()
* [Horaire et disponibilités H2026 - À suivre]()
* [Description de l'épreuve synthèse - À suivre]()

---
## Évaluation H26
* Projet de mi-session - TP01 : 30%
* Épreuve synthèse volet A - Examen pratique : 30%
* Épreuve synthèse volet B - TP02 : 40%

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
* [10 - Docker – Les réseaux](Documentation/Docker/Introduction-aux-réseaux.md)
* [11 - Docker – Application multi-services](Documentation/Docker/Application-multi-services.md)
* [12 - Docker – Retour sur les fusions (bind)](Documentation/Docker/Retour-sur-les-fusions-Bind.md)
* [13 - Dockerfile – Atelier de renforcement - SuperMinou 🐈](Documentation/Docker/Dockerfile-atelier-de-renforcement.md)
* [14a- Docker-Compose – Partie 1](Documentation/Docker/Docker-compose-p1.md)
* [14b- Docker-Compose – Partie 2](Documentation/Docker/Docker-compose-p2.md)
* [15 - Docker-Compose – Laboratoire (Drupal) TODO:](https://4204d4.ve2cuy.com/docker-compose-laboratoire-drupal/) 🛑
* [16 - Dépôt privé d’images – Harbor](Installation/Registre-privé-d-images.md)
* [17 - Automatisation des builds – GitHub actions](/Documentation/Automatisation/github-action.md)
* [18 - Automatisation des builds – GitHub actions V2](/Documentation/Automatisation/github-action-v2.md)
* [19 - Introduction à Homepage](Documentation/Docker/homepage.md)
* [Docker - Référence rapide](Documentation/Docker/Docker-Référence-rapide.md) 👍
* [Projet de mi-session : 30%](https://github.com/ve2cuy/420-4D4.TP01.Depart)

### Kubernetes (K8s)

* [20 - Kubernetes – Installation d'un nœud unique sous Linux](Documentation/Kubernetes/Installation-un-seul-noeud.md) 👍
* [21 - Kubernetes – Introduction](Documentation/Kubernetes/Kubernetes-Introduction.md) 👍
* [21a- Kubernetes – Manifestes expliqués - version courte](Documentation/Kubernetes/Kubernetes-Manifestes-Expliques-version-courte.md)
* [21b- Kubernetes – Manifestes expliqués - version longue](Documentation/Kubernetes/Kubernetes-Manisfestes-Expliques-version-longue.md)
* [22 - Kubernetes – Partie 2](Documentation/Kubernetes/Kubernetes-partie-2.md) 👍
* [22b- Kubernetes – Config Map et Secrets](Documentation/Kubernetes/Kubernetes-Config-map-et-secret.md) 👍
* [23 - Préparation à l'atelier d'installation d'un 'cluster' K8s avec Vagrant](https://4204d4.ve2cuy.com/pre-requis-atelier-k8s-vagrant/)
* [24 - Kubernetes – Installation d'un cluster; 1 Master, 2 Nodes](https://4204d4.ve2cuy.com/kubernetes-installation-dun-cluster-1-master-2-nodes/)
* [25 - Kubernetes – Les volumes](Documentation/Kubernetes/Kubernetes-Les-volumes.md) 👍
* [25a - Kubernetes - Services](Documentation/Kubernetes/Kubernetes-Services.md) 🧠
* [26 - Kubernetes – LoadBalancer Externe et Ingress](Documentation/Kubernetes/Kubernetes-LoadBalancer-et-Ingress.md) 👍 [Docum officielle](https://kubernetes.io/docs/concepts/services-networking/ingress/)
* [Ingress avec Traefik](Documentation/Kubernetes/Ingress-avec-traefik.md)
* [Équilibreur de charge externe](Documentation/Kubernetes/Equilibreur-de-charge-externe-MetalLB.md) 
* [Nouveaux services réseaux pour l'implémentation d'Ingress]() 🧠
* [27 - Espaces de nom (namespaces)]() 🧠
* [ServiceAccount]() 🧠
* [28 - Utilisation d’un cluster sur Google Cloud]() 🧠
* [29 - Helm charts]() 🧠
* [30 - Automatisation des ‘builds’ d’images Docker/Github]() 🧠
* [31 - Aide rapide]()
* [32 - Épreuve synthèse Volet A : 30 %]
* [33 - Épreuve synthèse Volet B : 40 %]
* [kubectl - Référence rapide](Documentation/Kubernetes/Kubernetes-Reference-rapide.md) 👍

---

### Outils

* [Les copier/coller](Documentation/CopierColler.md) 👍
* [LazyDocker](https://github.com/jesseduffield/lazydocker)
* [K9s](https://k9scli.io/)
* [Arcane](https://getarcane.app/)
* [Portainer](https://www.portainer.io/)
* [Rancher](https://www.rancher.com/quick-start)
* [LongHorn](https://longhorn.io/)

### Évaluations et Automatisation

* [Énoncé du TP01 – Docker - Version 2023 (30%)](https://4204d4.ve2cuy.com/tp01-docker/)
* [Énoncé du TP02 – K8s – Node-red+mosquitto+configmap+secret (20%)](https://4204d4.ve2cuy.com/tp02-k8s/)
* [Automatisation des 'builds' d'images Docker/Github](https://4204d4.ve2cuy.com/docker-github-actions/)
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
