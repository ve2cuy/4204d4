# Introduction à Homepage

## Qu'est-ce que Homepage ?

**Homepage** est un tableau de bord personnalisable et moderne pour centraliser l'accès à tous vos services auto-hébergés, applications web et ressources réseau. Conçu pour les utilisateurs de homelab et les administrateurs système, Homepage offre une interface élégante qui regroupe vos services avec des informations en temps réel.

### Caractéristiques principales

- Interface web responsive et personnalisable
- Intégration avec plus de 100 services populaires
- Affichage de widgets (météo, recherche, statistiques système)
- Configuration simple via fichiers YAML
- Support Docker natif avec détection automatique
- Thèmes clairs et sombres

## Installation

### Avec Docker (recommandé)

```bash
$ mkdir ./homepage-config
$ docker run -d \
  --name homepage \
  -p 3000:3000 \
  -e HOMEPAGE_ALLOWED_HOSTS=* \
  -v ./homepage-config:/app/config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/gethomepage/homepage:latest

# Après le lancement du contenur, il devrait y avoir des fichiers de configuration dans le dossier ./homepage-config
$ ls -l ./homepage-config

-rw-r--r-- 1   354 janv.  7 10:17 bookmarks.yaml
-rw-rw-r-- 1     0 déc.  10 11:47 custom.css
-rw-rw-r-- 1     0 déc.  10 11:47 custom.js
-rw-r--r-- 1   196 janv.  7 10:17 docker.yaml
-rw-rw-r-- 1    31 janv.  7 10:13 kubernetes.yaml
drwxr-xr-x 2  4096 janv.  7 10:13 logs
-rw-r--r-- 1   104 janv.  7 10:17 proxmox.yaml
-rw-r--r-- 1   506 janv.  7 10:27 services.yaml
-rw-r--r-- 1   184 janv.  7 10:13 settings.yaml
-rw-r--r-- 1   218 janv.  7 10:17 widgets.yaml
```

Accédez ensuite à `http://localhost:3000`

---

## Configuration de base

Homepage utilise des fichiers YAML dans le dossier `config/`. Les trois fichiers principaux sont :

- `services.yaml` : liste des services (applications)
- `widgets.yaml` : widgets du tableau de bord
- `settings.yaml` : paramètres généraux

---

### Exemple 1 : Ajouter des services simples

Créez ou modifiez `config/services.yaml` :

```bash
$ nano ./homepage-config/services.yaml
```

Et y ajouter le contenu suivant:

```yaml
---
- Média:
    - Plex:
        href: http://192.168.1.100:32400
        description: Serveur multimédia
        icon: plex.png

    - Jellyfin:
        href: http://192.168.1.101:8096
        description: Alternative à Plex
        icon: jellyfin.png

- Gestion:
    - Portainer:
        href: https://portainer.local
        description: Gestion Docker
        icon: portainer.png

    - Proxmox:
        href: https://proxmox.local:8006
        description: Virtualisation
        icon: proxmox.png
```

💡NOTE: Les changements devraient être actualisés automatiquement sur la page webé

---

### Exemple 2 : Ajouter des widgets informatifs

Éditez `homepage-config/widgets.yaml` :

```yaml
- search:
    provider: google
    target: _blank

- datetime:
    text_size: xl
    format:
      dateStyle: long
      timeStyle: short

- openmeteo:
    label: Gatineau
    latitude: 45.48
    longitude: -75.65
    units: metric
    cache: 5
```

👉 NOTE: Nous ajusterons l'interface au français à une étape suivante.

---

### Exemple 3 : Intégrations avec API

Pour afficher des statistiques en temps réel, ajoutez des intégrations dans `services.yaml` :

```yaml
- Surveillance:
    - Serveur Principal:
        href: http://192.168.1.50
        description: Stats système
        icon: linux.png
        widget:
          type: glances
          url: http://192.168.1.50:61208
          metric: cpu

    - Pi-hole:
        href: http://192.168.1.10/admin
        description: Blocage pub DNS
        icon: pi-hole.png
        widget:
          type: pihole
          url: http://192.168.1.10 
          key: votrecleapi123456
```

### Exemple 3.5 : Intégrations avec API sous Docker

Si les services roulent sous docker, alors voici la syntaxe à utiliser.

3.5.1 - Éditer le fichier ./homepage-config/docker.yaml et ajouter les directives suivantes:

```yaml
# Le label suivant servira de lien entre le service et docker
my-docker:
  socket: /var/run/docker.sock
```

3.5.2 - Remplacer le service pihole (dans ./homepage-config/services.yaml) par,

```yaml
    - Accès à PiHole:
        # https://gethomepage.dev/widgets/services/pihole/
        icon: pi-hole.png
        href: https://localhost/admin
        description: Interface d'administration PiHole
        server: my-docker # Le serveur docker, configuré dans docker.yaml
        container: pihole # Le nom du conteneur. Le réseau docker sera utilisé pour la connexion.
        showStats: true 
        target: _self 
```


---

### Exemple 4 : Personnalisation visuelle

Configurez `homepage-config/settings.yaml` :

```yaml
title: Mon Homelab
theme: dark
color: slate

layout:
  Média:
    style: row
    columns: 3
  Gestion:
    style: row
    columns: 2

favicon: https://votresite.com/favicon.ico
```

## Conseils d'utilisation

**Organisation** : Regroupez vos services par catégorie logique (Média, Réseau, Administration, etc.)

**Sécurité** : Si Homepage est exposé sur Internet, protégez-le derrière un reverse proxy avec authentification (Authelia, Authentik)

**Performance** : Ajustez le paramètre `cache` des widgets pour réduire les appels API fréquents

**Docker** : Utilisez des labels Docker pour une configuration automatique plutôt que manuelle

---

## Ressources

- Documentation officielle : https://gethomepage.dev
- Dépôt GitHub : https://github.com/gethomepage/homepage
- Liste des intégrations : https://gethomepage.dev/widgets/

---

## Conclusion

Homepage transforme votre collection de services en un portail unifié et professionnel, parfait pour gérer efficacement votre infrastructure personnelle ou professionnelle.

---


## Crédits

*Document préparé par Alain Boudreault © 2026*  
*Version 2026.01.07.1*  
*Site par ve2cuy*
