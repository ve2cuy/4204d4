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
docker run -d \
  --name homepage \
  -p 3000:3000 \
  -v /chemin/vers/config:/app/config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/gethomepage/homepage:latest
```

Accédez ensuite à `http://localhost:3000`

## Configuration de base

Homepage utilise des fichiers YAML dans le dossier `config/`. Les trois fichiers principaux sont :

- `services.yaml` : liste de vos services
- `widgets.yaml` : widgets du tableau de bord
- `settings.yaml` : paramètres généraux

### Exemple 1 : Ajouter des services simples

Créez ou modifiez `config/services.yaml` :

```yaml
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

### Exemple 2 : Ajouter des widgets informatifs

Éditez `config/widgets.yaml` :

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

### Exemple 4 : Personnalisation visuelle

Configurez `config/settings.yaml` :

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
