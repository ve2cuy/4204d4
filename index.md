---
layout: accueil
bandeau: "420-4D4-JR · techniques de l'informatique · cégep de saint-jérôme"
titre: "Serveurs Internet."
accroche: "Introduction à Docker et Kubernetes : conteneurs, images, Docker Compose, puis orchestration, volumes, services et déploiement continu."
image: Documentation/images/serveurs-entete.png
---

## Présentation sommaire du cours

![](dessins/fiche-info.svg)

Ce cours permettra à l'étudiant, à partir de l'approche DevOps, de réaliser, de documenter et d'automatiser les cycles d'édition, de production et de distribution d'une application en utilisant des outils d'intégration et de déploiement continus (CI/CD). À la fin du cours, l'étudiant sera en mesure d'utiliser un outil de type orchestration de conteneurs, permettant d'automatiser les parties du développement logiciel liées aux builds, aux tests et au déploiement.

- **Programme** : 420.B0 · Techniques de l'informatique
- **Famille** : Soutien aux utilisateurs et réseau
- **Pondération** : 1-3-2
- **Préalable** : 420-3C3-JR

Évaluation, hiver 2026 :

- **Projet de mi-session** : TP01 sur Docker · 30 %
- **Épreuve synthèse, volet A** : TP02 sur K8s · 35 %
- **Épreuve synthèse, volet B** : examen pratique, semaine 16 · 35 %

## Horaire et disponibilités de l'enseignant

![](dessins/enseignant.svg)

![Alain Boudreault](Documentation/images/moi.jpg)

**Alain Boudreault**, enseignant au département de Techniques de l'informatique, Cégep de Saint-Jérôme

- **Courriel** : [Aboudrea@cstj.qc.ca](mailto:Aboudrea@cstj.qc.ca)
- **Téléphone** : poste 6516
- **Local** : D125e

[Disponibilités pour la session H26](Documentation/images/Horaire-H26.png) · [Calendrier scolaire H26 (PDF)](Documentation/Contenu/Calendriers_H26_CSTJ.pdf)

## A) Plan de cours

![](dessins/porte-documents.svg) *Plan de cours, contenus et copier/coller*

- ![](dessins/document.svg) + · [Plan de cours, hiver 2026 (PDF)](Documentation/420-4D4-JR_ab_pc_H26.pdf)
- ![](dessins/livres.svg) + · [Contenus du cours](Documentation/Contenu/)
- ![](dessins/copier-coller.svg) + · [Les copier/coller](Documentation/CopierColler.md) · 👍
- ![](dessins/document.svg) + · Description de l'épreuve synthèse · à suivre

## B) Concepts et outils de base (Docker)

![](dessins/conteneur.svg) *Conteneurs, images, Dockerfile, Compose*

- ![](dessins/conteneur-vm.svg) 01 · [Conteneurs vs machines virtuelles](Documentation/Docker/Intro-a-docker-et-kubernetes.md)
- ![](dessins/telechargement.svg) 02 · [Installation de Docker](Installation/Docker/Installation-de-Docker.md)
- ![](dessins/conteneur.svg) 03 · [Docker – Introduction](Documentation/Docker/Introduction-a-Docker.md)
- ![](dessins/yaml.svg) 04 · [Yaml – Introduction](Documentation/Yaml/yaml.md)
- ![](dessins/livres.svg) 05 · [Référence Yaml](Documentation/Yaml/yaml-reference.md)
- ![](dessins/document.svg) 06 · [Yaml – Exemple d'un document Yaml](Documentation/Yaml/yaml-exemple-ibm.md)
- ![](dessins/nuage.svg) 07 · [hub.docker.com – Introduction](Documentation/Docker/Docker-Hub.md)
- ![](dessins/couches.svg) 08 · [Dockerfile – Introduction](Documentation/Docker/Dockerfile-Introduction.md)
- ![](dessins/etiquette.svg) 08b · [Dockerfile – Convention de nommage des « labels »](Documentation/Docker/Dockerfile-convention-de-nommage.md)
- ![](dessins/terminal.svg) 09 · [Dockerfile – Exemple avec une app node.js](Documentation/Docker/Dockerfile-Exemple-node.js.md)
- ![](dessins/chat.svg) F1 · [Dockerfile – Formatif 01 – SuperMinou 🐈](Documentation/Docker/Dockerfile-atelier-de-renforcement.md) · formatif
- ![](dessins/reseau.svg) 10 · [Docker – Les réseaux](Documentation/Docker/Introduction-aux-reseaux.md)
- ![](dessins/multi-services.svg) 11 · [Docker – Application multi-services](Documentation/Docker/Application-multi-services.md)
- ![](dessins/dossier-lien.svg) 12 · [Docker – Retour sur les fusions (bind)](Documentation/Docker/Retour-sur-les-fusions-Bind.md)
- ![](dessins/compose.svg) 13a · [Docker-Compose – Partie 1](Documentation/Docker/Docker-compose-p1.md)
- ![](dessins/compose.svg) 13b · [Docker-Compose – Partie 2](Documentation/Docker/Docker-compose-p2.md)
- ![](dessins/compose.svg) 13c · [Docker-Compose – Partie 3](Documentation/Docker/Docker-compose-p3.md)
- ![](dessins/fiole.svg) 14 · [Docker-Compose – Laboratoire (Drupal)](Documentation/Docker/Docker-compose-laboratoire-Drupal.md) · à revoir 🛑
- ![](dessins/registre.svg) 15 · [Dépôt privé d'images – Harbor](Installation/Registre-prive-d-images.md)
- ![](dessins/engrenage.svg) 16 · [Automatisation des builds – GitHub Actions](Documentation/Automatisation/github-action.md)
- ![](dessins/engrenage.svg) 17 · [Automatisation des builds – GitHub Actions V2](Documentation/Automatisation/github-action-v2.md)
- ![](dessins/tableau-de-bord.svg) 18 · [Introduction à Homepage](Documentation/Docker/homepage.md)
- ![](dessins/livres.svg) + · [Docker – Référence rapide](Documentation/Docker/Docker-Reference-rapide.md) · 👍

## C) Kubernetes (K8s)

![](dessins/roue.svg) *Orchestration, manifestes, volumes, services*

- ![](dessins/serveur.svg) 20 · [Kubernetes – Installation d'un nœud unique sous Linux](Documentation/Kubernetes/Installation-un-seul-noeud.md) · 👍
- ![](dessins/roue.svg) 21 · [Kubernetes – Introduction](Documentation/Kubernetes/Kubernetes-Introduction.md) · 👍
- ![](dessins/terminal.svg) 21b · [Kubernetes – kubectl, renforcement](Documentation/Kubernetes/Kubernetes-Introduction-kubectl.md)
- ![](dessins/yaml.svg) 22 · [Kubernetes – Manifestes expliqués, version courte](Documentation/Kubernetes/Kubernetes-Manifestes-Expliques-version-courte.md)
- ![](dessins/yaml.svg) 23 · [Kubernetes – Manifestes expliqués, version longue](Documentation/Kubernetes/Kubernetes-Manisfestes-Expliques-version-longue.md)
- ![](dessins/jauge.svg) 24 · [Kubernetes – Manifestes, gestion des ressources](Documentation/Kubernetes/Kubernetes-Manifestes-Gestion-des-ressources.md)
- ![](dessins/roue.svg) 25 · [Kubernetes – Partie 2](Documentation/Kubernetes/Kubernetes-partie-2.md) · 👍
- ![](dessins/cle.svg) 26 · [Kubernetes – Config Map et Secrets](Documentation/Kubernetes/Kubernetes-Config-map-et-secret.md) · 👍
- ![](dessins/jauge.svg) 27 · [Kubernetes – Gestion des ressources](Documentation/Kubernetes/Kubernetes-Manifestes-Gestion-des-ressources.md) · 👍
- ![](dessins/cluster.svg) 28 · Préparation à l'atelier d'installation d'un cluster K8s avec Vagrant
- ![](dessins/cluster.svg) 29 · [Kubernetes – Installation d'un cluster; 1 Master, 2 Nodes](Documentation/Kubernetes/Kubernetes-Installation-cluster.md)
- ![](dessins/disque.svg) 30 · [Kubernetes – Les volumes](Documentation/Kubernetes/Kubernetes-Les-volumes.md) · 👍
- ![](dessins/disque.svg) 30b · [Kubernetes – Les volumes, partie 2](Documentation/Kubernetes/Kubernetes-Volumes-p2.md) · 🧠
- ![](dessins/reseau.svg) 31 · [Kubernetes – Services](Documentation/Kubernetes/Kubernetes-Services.md) · 🧠
- ![](dessins/balance.svg) 32 · [LoadBalancer et ingress avec Traefik](Documentation/Kubernetes/MetalLB-Traefik.md)
- ![](dessins/balance.svg) 33 · [Kubernetes – LoadBalancer externe et ingress avec Nginx](Documentation/Kubernetes/Kubernetes-LoadBalancer-et-Ingress.md) · désuet
- ![](dessins/balance.svg) 34 · [Équilibreur de charge externe MetalLB – info supplémentaire](Documentation/Kubernetes/Equilibreur-de-charge-externe-MetalLB.md)
- ![](dessins/espaces.svg) 35 · Espaces de nom (namespaces) · 🧠
- ![](dessins/badge.svg) 36 · ServiceAccount · 🧠
- ![](dessins/nuage.svg) 37 · [Utilisation d'un cluster sur Google Cloud](Documentation/Kubernetes/Kubernetes-Google.cloud.md) · 🧠
- ![](dessins/roue.svg) 38 · [Helm – Introduction](Documentation/Kubernetes/Helm-introduction.md) · 👍
- ![](dessins/engrenage.svg) 39 · Automatisation des builds d'images Docker/GitHub · 🧠
- ![](dessins/autoscale.svg) 40 · [Autoscaling](Documentation/Kubernetes/Kubernetes-autoscalling.md) · 👍
- ![](dessins/livres.svg) 99 · [kubectl – Référence rapide](Documentation/Kubernetes/Kubernetes-Reference-rapide.md) · 👍

## D) Projets et épreuve synthèse

![](dessins/drapeau.svg) *TP01, volets A et B, énoncés 2023*

- ![](dessins/conteneur.svg) 1 · [Projet de mi-session – TP01 Docker](https://github.com/ve2cuy/4204D4-TP01-H26-depart) · 30 %
- ![](dessins/coupe.svg) 2 · [Épreuve synthèse, volet A – TP02 K8s](Documentation/Projet-Session/README.md) · 35 %
- ![](dessins/crayon.svg) 3 · Épreuve synthèse, volet B – examen pratique · 35 %

Énoncés des années précédentes :

- ![](dessins/document.svg) + · Énoncé du TP01 – Docker, version 2023 · 30 %
- ![](dessins/document.svg) + · [Énoncé du TP02 – K8s, Node-red + mosquitto + configmap + secret](Documentation/Kubernetes/Kubernetes-Node-RED-Mosquitto.md) · 20 %
- ![](dessins/document.svg) + · [Énoncé de l'épreuve synthèse, version 2023](Documentation/Projet-Session/Epreuve-synthese-2023.md) · 50 %

## E) Laboratoires et outils

![](dessins/cle-a-molette.svg) *Laboratoires, outils et scripts*

- ![](dessins/fiole.svg) 60 · [Google Cloud, NFS et Harbor](Documentation/Laboratoires/NFS-Habor.md) · laboratoire
- ![](dessins/terminal.svg) + · [LazyDocker](https://github.com/jesseduffield/lazydocker)
- ![](dessins/terminal.svg) + · [K9s](https://k9scli.io/)
- ![](dessins/tableau-de-bord.svg) + · [Arcane](https://getarcane.app/)
- ![](dessins/tableau-de-bord.svg) + · [Portainer](https://www.portainer.io/)
- ![](dessins/roue.svg) + · [Rancher](https://www.rancher.com/quick-start)
- ![](dessins/disque.svg) + · [LongHorn](https://longhorn.io/)
- ![](dessins/serveur.svg) + · [Script d'installation d'un serveur K8s](Installation/Kubernetes/script-serveur.md)
- ![](dessins/serveur.svg) + · [Script d'installation d'un nœud K8s](Installation/Kubernetes/script-noeud.md)
