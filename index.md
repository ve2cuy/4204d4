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

- ![](dessins/document.svg) - · [Plan de cours](Documentation/420-4D4-JR_ab_pc_H26.pdf)
  - Hiver 2026 · PDF officiel
- ![](dessins/livres.svg) - · [Contenus du cours](Documentation/Contenu/)
  - Le dossier des contenus de la session
- ![](dessins/copier-coller.svg) - · [Les copier/coller](Documentation/CopierColler.md) · 👍
  - Commandes et alias Docker et K8s · stubs Compose et K8s · scripts d'installation
- ![](dessins/document.svg) - · Description de l'épreuve synthèse · à suivre

## B) Concepts et outils de base (Docker)

![](dessins/conteneur.svg) *Conteneurs, images, Dockerfile, Compose*

- ![](dessins/conteneur-vm.svg) 01 · [Conteneurs et machines virtuelles](Documentation/Docker/Intro-a-docker-et-kubernetes.md)
  - VM et conteneurs · Docker et Kubernetes · Podman, Buildah, Kaniko
- ![](dessins/telechargement.svg) 02 · [Installation de Docker](Installation/Docker/Installation-de-Docker.md)
  - Docker Desktop · Ubuntu · Vagrant · Windows et macOS
- ![](dessins/conteneur.svg) 03 · [Introduction à Docker](Documentation/Docker/Introduction-a-Docker.md)
  - Commandes de base : run, ps, images, exec · ports IP · logs et inspect
- ![](dessins/yaml.svg) 04 · [YAML – Introduction](Documentation/Yaml/yaml.md)
  - Commentaires · scalaires · listes et structures · nœuds réutilisables
- ![](dessins/livres.svg) 05 · [Référence YAML](Documentation/Yaml/yaml-reference.md)
  - Règles, types de données, collections, ancres · pièges courants
- ![](dessins/document.svg) 06 · [Exemple d'un document YAML](Documentation/Yaml/yaml-exemple-ibm.md)
  - Un exemple complexe et sa conversion en JSON
- ![](dessins/nuage.svg) 07 · [Docker Hub](Documentation/Docker/Docker-Hub.md)
  - Publier une image personnalisée · stockage persistant
- ![](dessins/couches.svg) 08 · [Dockerfile – Introduction](Documentation/Docker/Dockerfile-Introduction.md)
  - FROM, RUN, COPY, ENV, WORKDIR, EXPOSE · CMD et ENTRYPOINT · cache
- ![](dessins/etiquette.svg) 09 · [Convention de nommage des labels](Documentation/Docker/Dockerfile-convention-de-nommage.md)
  - Métadonnées des images · org.label-schema et OCI
- ![](dessins/terminal.svg) 10 · [Image d'une application Node.js](Documentation/Docker/Dockerfile-Exemple-node.js.md)
  - Dockerfile · Express.js · arguments · image multi-plateforme
- ![](dessins/chat.svg) 11 · [SuperMinou 🐈](Documentation/Docker/Dockerfile-atelier-de-renforcement.md) · formatif
  - Dockerfile – formatif 01 de l'épreuve synthèse, volet B
- ![](dessins/reseau.svg) 12 · [Les réseaux Docker](Documentation/Docker/Introduction-aux-reseaux.md)
  - Réseaux host et macvlan
- ![](dessins/multi-services.svg) 13 · [Application multi-services](Documentation/Docker/Application-multi-services.md)
  - Variables d'environnement · MariaDB + Adminer
- ![](dessins/dossier-lien.svg) 14 · [Retour sur les fusions (bind)](Documentation/Docker/Retour-sur-les-fusions-Bind.md)
  - Dossiers liés · Node-RED, MySQL et WordPress · Portainer
- ![](dessins/compose.svg) 15 · [Docker Compose – Partie 1](Documentation/Docker/Docker-compose-p1.md)
  - Services, options et configuration
- ![](dessins/compose.svg) 16 · [Docker Compose – Partie 2](Documentation/Docker/Docker-compose-p2.md)
  - Multi-services · build · variables et fichier .env
- ![](dessins/compose.svg) 17 · [Docker Compose – Partie 3](Documentation/Docker/Docker-compose-p3.md)
  - Services d'initialisation · depends_on · healthcheck
- ![](dessins/fiole.svg) 18 · [Laboratoire Drupal](Documentation/Docker/Docker-compose-laboratoire-Drupal.md) · à revoir 🛑
  - Docker Compose : Drupal et sa base de données
- ![](dessins/registre.svg) 19 · [Dépôt privé d'images – Harbor](Installation/Registre-prive-d-images.md)
  - Installation · registre non sécurisé · droits d'accès
- ![](dessins/engrenage.svg) 20 · [GitHub Actions](Documentation/Automatisation/github-action.md)
  - Build et push automatiques vers Docker Hub
- ![](dessins/engrenage.svg) 21 · [GitHub Actions, version 2](Documentation/Automatisation/github-action-v2.md)
  - Projet complet de CI/CD : application, workflows, releases
- ![](dessins/tableau-de-bord.svg) 22 · [Homepage](Documentation/Docker/homepage.md)
  - Tableau de bord des services · configuration et widgets
- ![](dessins/livres.svg) 23 · [Docker – Référence rapide](Documentation/Docker/Docker-Reference-rapide.md) · 👍
  - Les commandes Docker essentielles

## C) Kubernetes (K8s)

![](dessins/roue.svg) *Orchestration, manifestes, volumes, services*

- ![](dessins/serveur.svg) 24 · [Installation d'un nœud unique](Documentation/Kubernetes/Installation-un-seul-noeud.md) · 👍
  - Amas K8s d'un seul serveur sous Linux · worker · kind
- ![](dessins/roue.svg) 25 · [Kubernetes – Introduction](Documentation/Kubernetes/Kubernetes-Introduction.md) · 👍
  - Minikube et kubectl · pods et déploiements · manifestes
- ![](dessins/terminal.svg) 26 · [kubectl, renforcement](Documentation/Kubernetes/Kubernetes-Introduction-kubectl.md)
  - run, create, expose, scale, logs · conteneur d'initialisation
- ![](dessins/yaml.svg) 27 · [Manifestes expliqués, version courte](Documentation/Kubernetes/Kubernetes-Manifestes-Expliques-version-courte.md)
  - Pod, Deployment, ConfigMap, Secret, Service
- ![](dessins/yaml.svg) 28 · [Manifestes expliqués, version longue](Documentation/Kubernetes/Kubernetes-Manisfestes-Expliques-version-longue.md)
  - Chaque ressource, avec des exemples commentés
- ![](dessins/jauge.svg) 29 · [Manifestes, gestion des ressources](Documentation/Kubernetes/Kubernetes-Manifestes-Gestion-des-ressources.md)
  - requests et limits · CPU et mémoire
- ![](dessins/roue.svg) 30 · [Kubernetes – Partie 2](Documentation/Kubernetes/Kubernetes-partie-2.md) · 👍
  - MongoDB + Mongo Express · laboratoires WordPress et PostgreSQL
- ![](dessins/cle.svg) 31 · [ConfigMap et Secrets](Documentation/Kubernetes/Kubernetes-Config-map-et-secret.md) · 👍
  - envFrom · volume à partir d'un configmap · secrets
- ![](dessins/jauge.svg) 32 · [Gestion des ressources](Documentation/Kubernetes/Kubernetes-Manifestes-Gestion-des-ressources.md) · 👍
  - Qualité de service : Guaranteed, Burstable, BestEffort
- ![](dessins/cluster.svg) 33 · Préparation de l'atelier cluster K8s
  - Installation d'un cluster avec Vagrant
- ![](dessins/cluster.svg) 34 · [Installation d'un cluster](Documentation/Kubernetes/Kubernetes-Installation-cluster.md)
  - 1 master, 2 nodes · Vagrant · kubeadm
- ![](dessins/disque.svg) 35 · [Les volumes](Documentation/Kubernetes/Kubernetes-Les-volumes.md) · 👍
  - emptyDir, hostPath, PV et PVC, NFS
- ![](dessins/disque.svg) 36 · [Les volumes, partie 2](Documentation/Kubernetes/Kubernetes-Volumes-p2.md) · 🧠
  - hostPath · stockage S3 : MinIO et Garage
- ![](dessins/reseau.svg) 37 · [Les services](Documentation/Kubernetes/Kubernetes-Services.md) · 🧠
  - ClusterIP, NodePort, LoadBalancer, ExternalName
- ![](dessins/balance.svg) 38 · [LoadBalancer et ingress avec Traefik](Documentation/Kubernetes/MetalLB-Traefik.md)
  - MetalLB · Traefik par Helm · Google Cloud et DuckDNS
- ![](dessins/balance.svg) 39 · [LoadBalancer et ingress avec Nginx](Documentation/Kubernetes/Kubernetes-LoadBalancer-et-Ingress.md) · désuet
  - MetalLB · ingress Nginx
- ![](dessins/balance.svg) 40 · [Équilibreur de charge MetalLB](Documentation/Kubernetes/Equilibreur-de-charge-externe-MetalLB.md)
  - Information supplémentaire : installation, Layer 2, Traefik
- ![](dessins/espaces.svg) 41 · Espaces de nom (namespaces) · 🧠
- ![](dessins/badge.svg) 42 · ServiceAccount · 🧠
- ![](dessins/nuage.svg) 43 · [Cluster sur Google Cloud](Documentation/Kubernetes/Kubernetes-Google.cloud.md) · 🧠
  - gcloud · contexte du cluster · facturation
- ![](dessins/roue.svg) 44 · [Helm – Introduction](Documentation/Kubernetes/Helm-introduction.md) · 👍
  - Charts, repositories et releases · exemples
- ![](dessins/engrenage.svg) 45 · Automatisation des builds d'images · 🧠
  - Docker et GitHub
- ![](dessins/autoscale.svg) 46 · [Autoscaling](Documentation/Kubernetes/Kubernetes-autoscalling.md) · 👍
  - HPA, VPA, Cluster Autoscaler, KEDA
- ![](dessins/livres.svg) 47 · [kubectl – Référence rapide](Documentation/Kubernetes/Kubernetes-Reference-rapide.md) · 👍
  - Pods, déploiements, services, contextes, namespaces

## D) Projets et épreuve synthèse

![](dessins/drapeau.svg) *TP01, volets A et B, énoncés 2023*

- ![](dessins/conteneur.svg) 48 · [Projet de mi-session – TP01](https://github.com/ve2cuy/4204D4-TP01-H26-depart) · 30 %
  - Docker · dépôt de départ sur GitHub
- ![](dessins/coupe.svg) 49 · [Épreuve synthèse, volet A](Documentation/Projet-Session/README.md) · 35 %
  - TP02 K8s · applications en local, puis en nuage
- ![](dessins/crayon.svg) 50 · Épreuve synthèse, volet B · 35 %
  - Examen pratique

Énoncés des années précédentes :

- ![](dessins/document.svg) 51 · Énoncé du TP01, version 2023 · 30 %
  - Docker
- ![](dessins/document.svg) 52 · [Énoncé du TP02](Documentation/Kubernetes/Kubernetes-Node-RED-Mosquitto.md) · 20 %
  - K8s : Node-RED + Mosquitto + ConfigMap + Secret
- ![](dessins/document.svg) 53 · [Épreuve synthèse, version 2023](Documentation/Projet-Session/Epreuve-synthese-2023.md) · 50 %
  - Infrastructure K8s H.A. · NextCloud et Mattermost

## E) Laboratoires et outils

![](dessins/cle-a-molette.svg) *Laboratoires, outils et scripts*

- ![](dessins/fiole.svg) 54 · [Google Cloud, NFS et Harbor](Documentation/Laboratoires/NFS-Habor.md) · laboratoire
  - Laboratoire en deux parties
- ![](dessins/terminal.svg) 55 · [LazyDocker](https://github.com/jesseduffield/lazydocker)
  - Interface en mode texte pour Docker
- ![](dessins/terminal.svg) 56 · [K9s](https://k9scli.io/)
  - Interface en mode texte pour Kubernetes
- ![](dessins/tableau-de-bord.svg) 57 · [Arcane](https://getarcane.app/)
  - Interface Web de gestion de Docker
- ![](dessins/tableau-de-bord.svg) 58 · [Portainer](https://www.portainer.io/)
  - Gestion de Docker et de Kubernetes par le Web
- ![](dessins/roue.svg) 59 · [Rancher](https://www.rancher.com/quick-start)
  - Gestion de clusters Kubernetes
- ![](dessins/disque.svg) 60 · [Longhorn](https://longhorn.io/)
  - Stockage distribué pour Kubernetes
- ![](dessins/serveur.svg) 61 · [Script d'installation d'un serveur K8s](Installation/Kubernetes/script-serveur.md)
  - server.sh
- ![](dessins/serveur.svg) 62 · [Script d'installation d'un nœud K8s](Installation/Kubernetes/script-noeud.md)
  - node.sh
