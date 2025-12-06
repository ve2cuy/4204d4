
# Dockerfile – Atelier de renforcement

 19 février 2021 - Révision du 2025-12-05

<p align="center">
    <img src="../images/renforcement.png" alt="chat" width="400" />
</p>

---

 ### Il faut bâtir une image Docker,  à partir d'un fichier Dockerfile nommé 'powercat' qui:
 
 * Utilise comme source de départ, **apache version 2.4**
 * Propose les applications suivantes:  **mc, curl, git, htop et mcedit**
 * Le site web doit proposer le contenu du répertoire **4204d4/module01/semaine02/exercice03** du dépôt GitHub **https://github.com/ve2cuy/4204d4.git** comme page d'accueil.
 
 **IMPORTANT**, il ne faut pas cloner le dépôt sur votre poste de travail mais plutôt dans l'image du conteneur, dans le répertoire **/420**.
 
 * Remplacer l'image **docker-logo.jpg** par celle-ci: 

<p align="center">
    <img src="../images/chat.png" alt="chat" width="350" />
</p>


  **NOTE**: Ne pas modifier les fichiers source, html, css, js, du site web.<br>


 * Remplacer le nom de l'auteur du pied de page dans **index.html** par votre nom.
 
  **NOTE**: Il faut utiliser la commande **'sed -i'**. Ne pas modifier le fichier avec un éditeur de texte. La modification doit-être faite dans le Dockerfile. Référence: Rechercher et remplacer une chaine de caractères sous Linux.
 
 * Le contenu de votre fichier Dockerfile doit être accessible à l'adresse: **http://localhost/info.txt**
 * Inscrire en commentaire, dans le fichier, la commande à utiliser pour produire l'image.; `# docker build …`
 * Il faut publier l'image finale sur docker hub sous: **votrecompte/docker-lab version latest et 1.0**
 
 ----

 ## Défi supplémentaire pour les plus téméraires
 
 * Créer l'utilisateur **gestionweb**
 * Renseigner **'donttell'** comme mot de passe
 * L'inscrire aux groupes **www-data et sudo**
 * Publier la version **2.0** de l'application
