
# Dockerfile – Atelier de renforcement, version H26

## NOTE: Cet atelier est un exercice formatif à l'épreuve synthèse volet B.
## Il ne faut pas utiliser l'IA pour réaliser ce laboratoire. 

### À remettre sur LEA.
---


<p align="center">
    <img src="../images/renforcement.png" alt="chat" width="400" />
</p>

---

### Il faut bâtir une image Docker,  à partir d'un fichier Dockerfile nommé `powercat` qui:
 

1. Utilise comme source de départ, 👉`ubuntu:22.04` <<-- **IMPORTANT**
2. Propose les applications suivantes:  `mc`, `curl`, `git`, `htop` et `mcedit`
3. Le site web doit proposer le contenu du dépôt GitHub **https://github.com/ve2cuy/superminou-depart** comme page d'accueil.
 
**IMPORTANT**, il ne faut pas cloner le dépôt sur votre poste de travail mais plutôt dans l'image du conteneur, dans le répertoire `/420`.

4. Renseigner la configuration d'apache pour gérer un erreur 404. Copier le fichier `404.html` dans le dossier `error/`
5. Renseigner la configuration d'apache pour gérer un erreur 403, de type `Too many requests`, via le module `mod_evasive`. Voir plus bas pour les détails. Copier le fichier `blocked.html` dans le dossier `error/`
   1. Utiliser un argument du build pour renseigner le `DOSPageCount`, `DOSPageInterval` et `DOSBlockingPeriod`
   2. Le module `mod-evasive` est requis et doit-être activé, `a2enmod`, pour ce point.
   3. `mod-evasive` gère les erreurs via 403.  Voici un exemple:

```bash 
# Trouver comment installer 'mod_evasive'
# Puis, configurer le module
<IfModule mod_evasive20.c>
    DOSHashTableSize    3097
    DOSPageCount        5  # Renseigné à partir d'un ARG
    DOSPageInterval     10 # Renseigné à partir d'un ARG
    DOSBlockingPeriod   60 # Renseigné à partir d'un ARG
</IfModule>
```

6. Remplacer l'image **docker-logo.jpg** par celle-ci: 

<p align="center">
    <img src="../images/chat.png" alt="chat" width="350" />
</p>

---

7. Remplacer le nom de l'auteur du pied de page dans **index.html** par votre nom.
8. Remplacer la photo, en haut à droite du menu, par la votre.
9. Renseigner trois labels:
   1.  auteur (votre nom et matricule) # org.opencontainers.image.authors
   2.  Titre de l'application
   3.  Source # Par exemple, "https://github.com/user/repo"

NOTE: Utiliser le standard OCI. Voir ce [Document](https://ve2cuy.github.io/4204d4/Documentation/Docker/Dockerfile-convention-de-nommage.html)


10.  Publier votre solution sur github.

---

**🤚 NOTE**: Il faut utiliser la commande **'sed -i'** pour éditer les fichiers. Ne pas modifier les fichiers avec un éditeur de texte. Les modifications doivent-être faites dans le Dockerfile. Référence: Rechercher et remplacer une chaine de caractères sous Linux.
 
* Le contenu de votre fichier Dockerfile doit être accessible à l'adresse: **http://localhost/info.txt**
* Inscrire en commentaire, dans le fichier, la commande à utiliser pour produire l'image.; `# docker build …`
* Il faut publier l'image finale sur docker hub sous: **votrecompte/docker-lab version latest et 1.0**

**💡Astuce** Utiliser, dans la Dockerfile, `ENV DEBIAN_FRONTEND=noninteractive` pour vous assurer qu'il n'y aura pas d'interactivité lors de l'installation des packages.
 
 ---

## Résultat

### Page principale

<img src="../images/superminou.png" alt="chat" width="750" />

### Bas de page
<img src="../images/super-minou-footer.png" alt="chat" width="750" />

---

### Page 404
<img src="../images/super-minou-404.png" alt="chat" width="750" />

### Page 403
<img src="../images/super-minou-403.png" alt="chat" width="750" />

 ----

## Défi supplémentaire pour les plus téméraires
 
 * Créer l'utilisateur **gestionweb**
 * Renseigner **'donttell'** comme mot de passe
 * L'inscrire aux groupes **www-data et sudo**
 * Publier la version **2.0** de l'application


---

Une version fonctionnelle est disponible via

```bash 
$ docker run -d -p 80:80 alainboudreault/labo:super-minou
```

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2026*  
*Version 2026.02.09.1*  
*Site par ve2cuy*