# Docker – Référence rapide

*2 Décembre 2025*

| **Commande** | **Description** | **Exemple** |
| :--- | :--- | :--- |
| `docker build -t IMAGE:TAG .` | Construire une image depuis un Dockerfile | `docker build -t myapp:1.0 .` |
| `docker build --no-cache -t IMAGE:TAG .` | Construire sans utiliser le cache | `docker build --no-cache -t myapp:1.0 .` |
| `docker buildx build --platform linux/amd64,linux/arm64 -t IMAGE:TAG .` | Construire multi-plateforme avec buildx | `docker buildx build --platform linux/amd64,linux/arm64 -t myapp:multi .` |
| `docker images` | Lister les images locales | `docker images` |
| `docker image ls --filter dangling=true` | Lister images dangling (non taggées) | `docker image ls --filter dangling=true` |
| `docker pull IMAGE` | Télécharger une image depuis un registre | `docker pull nginx:latest` |
| `docker tag SOURCE_IMAGE:TAG TARGET:TAG` | Retagger une image locale | `docker tag myapp:1.0 myrepo/myapp:1.0` |
| `docker push REPO/IMAGE:TAG` | Pousser une image vers un registre | `docker push myrepo/myapp:1.0` |
| `docker save -o file.tar IMAGE:TAG` | Exporter une image vers un fichier tar | `docker save -o myapp.tar myapp:1.0` |
| `docker load -i file.tar` | Importer une image depuis un fichier tar | `docker load -i myapp.tar` |
| `docker run --name NAME -d -p HOST:CONTAINER IMAGE` | Créer et lancer un conteneur en arrière-plan | `docker run --name web -d -p 80:80 nginx` |
| `docker run --rm -it IMAGE CMD` | Lancer un conteneur temporaire et le supprimer à la sortie | `docker run --rm -it alpine sh` |
| `docker run -v host_path:container_path -d IMAGE` | Monter un volume/chemin hôte dans le conteneur | `docker run -v /data:/app/data -d myapp` |
| `docker ps` | Lister conteneurs en cours d’exécution | `docker ps` |
| `docker ps -a` | Lister tous les conteneurs (y compris arrêtés) | `docker ps -a` |
| `docker stop CONTAINER` | Arrêter un conteneur en cours | `docker stop web` |
| `docker start CONTAINER` | Démarrer un conteneur arrêté | `docker start web` |
| `docker restart CONTAINER` | Redémarrer un conteneur | `docker restart web` |
| `docker rm CONTAINER` | Supprimer un conteneur arrêté | `docker rm web` |
| `docker rm -f CONTAINER` | Forcer la suppression d’un conteneur en cours | `docker rm -f old-container` |
| `docker rmi IMAGE` | Supprimer une image locale | `docker rmi myapp:1.0` |
| `docker image prune -a` | Supprimer images inutilisées | `docker image prune -a` |
| `docker container prune` | Supprimer tous les conteneurs arrêtés | `docker container prune` |
| `docker volume prune` | Supprimer volumes non utilisés | `docker volume prune` |
| `docker system prune -a` | **Nettoyer images, conteneurs, volumes et réseaux inutilisés** | `docker system prune -a` |
| `docker logs -f CONTAINER` | Afficher les logs d’un conteneur en continu | `docker logs -f web` |
| `docker logs --since 1h CONTAINER` | Afficher les logs depuis une période donnée | `docker logs --since 1h web` |
| `docker exec -it CONTAINER CMD` | Exécuter une commande dans un conteneur en cours | `docker exec -it web /bin/sh` |
| `docker exec -u USER -it CONTAINER CMD` | Exécuter une commande en tant qu’utilisateur spécifique | `docker exec -u 1000 -it web /bin/sh` |
| `docker cp SRC DEST` | Copier fichiers entre hôte et conteneur | `docker cp ./config.json web:/app/config.json` |
| `docker commit CONTAINER IMAGE:TAG` | Créer une image à partir d’un conteneur | `docker commit web myapp:from-web` |
| `docker inspect OBJECT` | Obtenir les détails JSON d’un conteneur ou image | `docker inspect web` |
| `docker inspect --format='{{.State.Running}}' CONTAINER` | Inspecter avec format Go template | `docker inspect --format='{{.State.Running}}' web` |
| `docker stats` | Afficher l’utilisation des ressources en temps réel | `docker stats` |
| `docker top CONTAINER` | Afficher les processus d’un conteneur | `docker top web` |
| `docker diff CONTAINER` | Montrer les changements de fichiers dans un conteneur | `docker diff web` |
| `docker rename OLD_NAME NEW_NAME` | Renommer un conteneur | `docker rename web web-old` |
| `docker wait CONTAINER` | Attendre la fin d’un conteneur et retourner son code de sortie | `docker wait web` |
| `docker attach CONTAINER` | Se rattacher à l’entrée/sortie d’un conteneur en cours | `docker attach web` |
| `docker pause CONTAINER` | Geler tous les processus d’un conteneur | `docker pause web` |
| `docker unpause CONTAINER` | Reprendre un conteneur gelé | `docker unpause web` |
| `docker update --memory=512m CONTAINER` | Mettre à jour les ressources d’un conteneur en cours | `docker update --memory=512m web` |
| `docker network ls` | Lister les réseaux Docker | `docker network ls` |
| `docker network rm NETWORK` | Supprimer un réseau Docker | `docker network rm mynet` |
| `docker volume ls` | Lister les volumes Docker | `docker volume ls` |
| `docker volume rm VOLUME` | Supprimer un volume Docker | `docker volume rm myvol` |
| `docker system df` | Afficher l’utilisation disque par Docker | `docker system df` |
| `docker login` | Se connecter à un registre Docker | `docker login` |
| `docker logout` | Se déconnecter d’un registre Docker | `docker logout` |
| `docker scan IMAGE` | Scanner une image pour vulnérabilités (Docker Scan) | `docker scan myapp:1.0` |
| `docker history IMAGE` | Voir l’historique des couches d’une image | `docker history myapp:1.0` |
| `docker compose up -d` | Lancer les services définis dans docker-compose / compose V2 | `docker compose up -d` |
| `docker compose build` | Construire les images définies par Compose | `docker compose build` |
| `docker compose down` | Arrêter et supprimer les ressources créées par Compose | `docker compose down` |
| `docker compose logs -f` | Suivre les logs des services Compose | `docker compose logs -f` |
| `docker context ls` | Lister les contexts Docker (ex. remote) | `docker context ls` |
| `docker context use NAME` | Bascule vers un contexte Docker | `docker context use my-remote` |