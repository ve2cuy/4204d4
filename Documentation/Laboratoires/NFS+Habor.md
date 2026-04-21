## Laboratoire NFS+Harbor

<img src="../images/labo02.png" alt="" width="700" />

### Partie 1

* À partir d'un clone de la VM principale, nommé Habor
* Réaliser le laboratoire [Harbor](https://ve2cuy.github.io/4204d4/Installation/Registre-priv%C3%A9-d-images.html)
    * NOTE: Ajuster à la version actuelle de Harbor

---

### Partie 2

En utilisant votre projet Google Cloud du Cégep, il faut:

* Créer une VM Ubuntu 24.04LTS sur us-central1, de type e2-small
* Installer un service NFS avec un partage sur le dossier /esh26
* Créer un fichier /esh26/index.html avec le texte de votre choix
* Installer Harbor, voir le [document](https://ve2cuy.github.io/4204d4/Installation/Registre-priv%C3%A9-d-images.html)
* Renseigner le firewall du projet pour exposer les ports requis pour NFS et Harbor
* Utiliser un service DNS gratuit - [duckdns](https://www.duckdns.org/) - pour pointer vers votre serveur
* Tester l'accès NFS à partir d'un poste local sous Linux
* Tester l'accès à Habor
* 