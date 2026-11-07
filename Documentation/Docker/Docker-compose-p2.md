# 🐳 Docker-compose – Introduction - Partie 2

<p align="center">
    <img src="../images/docker-compose-transparent.png" alt="YAML" width="350" />
</p>

## 3 – Mise en place d'une application multi-services (MariaDB + Adminer)

### Action 3.1 – Renseigner le fichier `docker-compose.yml`

Cet exemple utilise `depends_on` pour s'assurer que la base de données (`maBD`) démarre avant l'interface de gestion (`gestionBDviaAppWeb`).

```yaml

services:
  maBD:
    image: mariadb
    environment:
      - "MYSQL_ROOT_PASSWORD=root"
  gestionBDviaAppWeb:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - maBD
```


### Consolidation des exercices précédents (Exemple complet)

```yaml

services:
  srv01:
    image: alpine
    hostname: serveur01
    container_name: serveur01
    stdin_open: true
    tty: true
    networks:
      - reseauAlpine
    environment:
      - JESUIS=Le spécialiste de la paresse
    # command: sh

  srv02:
    image: alpine
    container_name: serveur02
    stdin_open: true
    tty: true
    networks:
      - reseauAlpine
    environment:
      - JESUIS=Celui qui fait du sur place
    command: top

  srv99:
    image: alpine
    container_name: serveur99
    stdin_open: true
    tty: true
    volumes:
      - ./:/420

  serveurweb:
    image: nginx
    container_name: serveurWEB
    volumes:
      - ./templates/site.template:/etc/nginx/templates
      - ./contenuweb:/usr/share/nginx/html:rw
    ports:
      - "8080:80"
    environment:
      - NGINX_HOST=monServeurWeb.com
      - NGINX_PORT=80

  maBD:
    image: mariadb
    networks:
      - reseauAdminer
    environment:
      - "MYSQL_ROOT_PASSWORD=root"

  gestionBDviaAppWeb:
    image: adminer
    networks:
      - reseauAdminer
    ports:
      - "8081:8080"
    depends_on:
      - maBD

networks:
  reseauAlpine:
    name: jeSuisLeReseauAlpine
    driver: bridge
  reseauAdminer:
    name: jeSuisLeReseauAdminer
    driver: bridge
```

-----
<img src="../images/labo03.png" alt="" width="700" />

## 4 – Laboratoire 1 (MySQL + phpMyAdmin)

Démarrer, à partir d'un fichier `docker-compose`, le système de micro-services suivants :

1.  **`mysql`**, avec le stockage local, dossier **`mesBD`**, des bases de données.
2.  **`phpmyadmin`**, sur le port **`88`**.
3.  Créer, à partir de `phpmyadmin`, la base de données **`wordpress`**.
4.  Vérifier que la BD a été créée sur votre disque local.

> **Note :** Si le fichier n'est pas nommé `docker-compose.yml`, alors il faut le nommer dans les commandes, par exemple :
>
>   * `docker compose -f docker-labo02.yml up -d`
>   * `docker compose -f docker-labo02.yml ps`
>   * `docker compose -f docker-labo02.yml exec cie_db bash`

-----

<img src="../images/labo02.png" alt="" width="700" />

## 5 – Laboratoire 2 (WordPress, MariaDB et phpMyAdmin)

Mettre en place un site WordPress, en utilisant `docker compose`, pour la **CIE\_ABC**, en respectant le devis suivant :

  * Un service **`mariadb` version 10.5**, nommé **`cie_db`** pour la base de données :
      * Port externe: `3333`
      * base de données: `cie_abc`
      * utilisateur: `cieuser`
      * Mot de passe: `ciepassword`
      * Mot de passe root: `donttell`
      * La base de données est stockée localement dans le dossier `cie_data2`
  * Un service **`WordPress version 5.6.2`** :
      * Renseigner les paramètres assurant le bon fonctionnement du site WordPress de la CIE ABC
      * port IP local: `80`
  * Un service **`phpMyadmin`** :
      * port IP Local: `8080`

Tester l'application WordPress de la CIE ABC et le service phpMyadmin.

-----

## 6 – Quelques commandes utiles

| Commande | Description |
| :--- | :--- |
| `docker compose config` | Valider le fichier `docker-compose.yml`. |
| `docker compose up` | Démarre les services et affiche les logs. |
| `docker compose up -d` | Démarre les services en arrière-plan (mode détaché). |
| `docker compose logs` | Affiche les logs de tous les services. |
| `docker compose ps` | Affiche l'état des services. |
| `docker compose stop` | Arrête les conteneurs (sans les supprimer). |
| `docker compose down` | Arrête et supprime les conteneurs, réseaux et volumes par défaut. |

-----

## 7 – Exemple de `docker compose` avec un `build`

`docker compose` permet la mise en place d'images personnalisées pendant le processus de démarrage d'une application multi-services.

### Action 7.1 – Enregistrer le fichier `Dockerfile`

Dans un dossier vide, enregistrer le fichier **`Dockerfile`** :

```
# ###########################################################################
# Fichier: Dockerfile
# Auteur: Alain Boudreault
# Date: 2021.03.05
# Description: Exemple d'un Dockerfile avec,
#
# 1 - Des variables d'environnement,
# 2 - Un invite de commande personnalisé pour tous les 'users',
# 3 - Le démarrage automatique d'une application du conteneur.
# ###########################################################################
FROM debian
LABEL authors="Alain Boudreault <aboudrea@cstj.qc.ca>"
LABEL Atelier="7.1 de https://ve2cuy.github.io/4204d4/Documentation/Docker/Docker-compose-p2.html"
ENV UN_MOT_DE_PASSE=tepasserieux
ENV UNE_BASE_DE_DONNEES=db_de_la_ciex
# Definir des variables avec des séquences ANSI pour afficher de la couleur sous BASH
ENV RESET="\[\033[0m]" \
    ROUGE="\[\033[0;31m]" \
    VERT="\[\033[01;32m]" \
    BLEU="\[\033[01;34m]" \
    JAUNE="\[\033[0;33m]"
# Sympathique petit (prompt) invite en couleur pour tous les utilisateurs

# ATTENTION, placer le symbole % devant H, M et S!
# TODO: RUN echo 'export PS1="${VERT}\D{H:M:S} - ${JAUNE}\u@docker${ROUGE}\nDossier: [\W]\n${RESET}\$ "' >> /etc/bash.bashrc
RUN apt-get update
RUN apt-get install git lynx -y
# Lancer le fureteur au démarrage. Tester avec http://lite.cnn.com/en
# CMD ["lynx", "http://lite.cnn.com/en"]
```

### Action 7.1b – Bâtir l'image (Test intermédiaire)

```bash
docker build -t perso .
```

> **Note :** Avec `docker compose`, il n'est pas nécessaire de bâtir l'image au préalable.

### Action 7.2 – Afficher les informations de l'image

```bash
docker inspect perso
```

> **Note :** Remarquer les propriétés `Author`, `Env` et `Labels`.

### Action 7.3 – Renseigner le fichier `docker-compose`

Ce fichier utilise l'instruction `build: .` pour indiquer à `docker compose` de construire l'image à partir du `Dockerfile` se trouvant dans le répertoire courant.

```yaml
# docker compose build
# docker compose up --build -d
# OU
# docker compose up -d
services:
  # Note: pas de caractères majuscules dans le nom du service
  mondebian:
    image: alainboudreault/serveur01
    container_name: serveur01
    build: .
    restart: always
    stdin_open: true # docker run -i
    tty: true # docker run -t
    environment:
      - VERSION=action7.1
    networks:
      - reseau7.1
  web:
    image: nginx:latest
    ports:
      - "8000:80"
    restart: always
    volumes:
      - ./web:/usr/share/nginx/html/perso
    networks:
      - reseau7.1

networks:
  reseau7.1:
    name: jeSuisLeReseau7.1
    driver: bridge
```

-----

## 9 – Utilisation de variables dans `docker-compose.yml`

Il est possible d'externaliser les variables de configuration dans un fichier **`.env`**.

### Action 9.1 – Le fichier **`.env`**

```properties
DB_PORT=3306
DB_ROOT_PASS=password
DB_USER=bob
DB_PASS=password
```

### Action 9.2 – Utilisation dans `docker-compose.yml`

```yaml
services:
  db:
    image: mariadb:10.4.13
    ports:
      - ${DB_PORT}:3306
    volumes:
      - ./db_data:/var/lib/mysql
    tmpfs:
      - /tmp/mysql-tmp
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "${DB_ROOT_PASS}"
      MYSQL_USER: "${DB_USER}"
      MYSQL_PASSWORD: "${DB_PASS}"
```

> **Note :** voir la directive `depends_on` pour gérer les dépendances entre services.

-----

## 10 - Serveur `httpd` avec port `http` via une variable d'environnement

```yaml
services:
  httpd:
    image: httpd:latest
    environment:
      - HTTPD_PORT=${HTTPD_PORT:-8080}
    ports:
      - "${HTTPD_PORT:-8080}:${HTTPD_PORT:-8080}"
    entrypoint: >
      sh -c "sed -i 's/^Listen 80/Listen '$$HTTPD_PORT'/' /usr/local/apache2/conf/httpd.conf && httpd-foreground"

```

💡NOTE: Le $$ est utilisé pour échapper le signe $ dans le contexte de Docker Compose.

Docker Compose interprète $VARIABLE comme une variable de substitution Compose (comme ${HTTPD_PORT})
Pour passer un vrai $ au shell du conteneur, il faut écrire $$.

* Contenu du fichier .env

```
HTTPD_PORT=88
```

👉 NOTE: Tester en laboratoire

----


## 11 – Configuration avancée d'un Nginx (substitution d'environnement)

Pour configurer dynamiquement Nginx à partir de variables d'environnement (`PORT=8080`), on utilise la substitution (`envsubst`).

### Fichier **`config.site`** (template)

```nginx
server {
    listen ${PORT};
    server_name localhost;
    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
    }
}
```

### Fichier **`docker-compose.yml`** (avec `envsubst`)

```yaml
web:
  image: nginx
  volumes:
    - ./site.template:/etc/nginx/conf.d/site.template
  ports:
    - "3000:8080"
  environment:
    - PORT=8080
  command: /bin/sh -c "envsubst < /etc/nginx/conf.d/site.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"
```

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2026*  
*Version 2026.02.19.1*  
*Site par ve2cuy*
