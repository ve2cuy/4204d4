# Laboratoire NFS+Harbor


<img src="../images/labo02.png" alt="" width="700" />

---

# 👉 Partie 1

* À partir d'un clone de la VM principale (`labo420`), nommé `Harbor`
* Réaliser le laboratoire [Harbor](https://ve2cuy.github.io/4204d4/Installation/Registre-priv%C3%A9-d-images.html)
    * **IMPORTANT:** 👉 Ajuster à la version actuelle de `Harbor`
    * 💡 `docker` doit être disponible pour installer `harbor` 
* Ajouter une référence au DNS local (windows) pour:
  * Avec PowerShell Admin-> code C:\WINDOWS\system32\drivers\etc\hosts
    * **harbor**  
    * **mon.registre.info**
---

<img src="../images/labo03.png" alt="" width="700" />

# 👉 Partie 2

---


En utilisant votre projet `Google Cloud` du Cégep, il faut:

* Créer une VM `Ubuntu 24.04LTS` sur `us-central1`, de type 👉 `e2-small`
  * Disque de 15go
  * Port HTTP ouvert
* Installer un service `NFS` avec un partage sur le dossier `/esh26`
  * Un document de référence est disponible --> [ici](https://ve2cuy.com/420-3c3/?page_id=2511)
  * ATTENTION: Ne pas créer le dossier dans votre dossier de travail mais bien dans `\`
  * Renseigner le `firewall` du projet pour exposer les ports requis pour `NFS`
    * 👉 Voir le document de référence
* Créer un fichier `/esh26/index.html` avec le texte de votre choix
* Utiliser un service DNS gratuit - [duckdns](https://www.duckdns.org/) - pour pointer vers votre serveur
  * Créer un domaine sur `duckdns`
  * Utiliser l'adresse `IP externe` de la VM
* Installer `Harbor`, voir le [document](https://ve2cuy.github.io/4204d4/Installation/Registre-priv%C3%A9-d-images.html)
  * NOTE: 💡 `docker` doit être disponible pour installer `harbor` 
  * 🛑 ATTENTION: Pensez à changer le mot de passe dans `harbor.yml`
    * `harbor_admin_password:`
  * Utiliser le nom de domaine de `duckdns` comme `hostname`
    * Par exemple, `hostname: 4204d4.duckdns.org` 
  * Utiliser le port 80
    * http:
      * port: 80
  * 🤚 Mettre en commentaire la section HTTPS
* Tester l'accès NFS à partir d'un poste local sous Linux
* Tester l'accès à Harbor


---

## 💡Défi supplémentaire (demandé lors de l'épreuve synthèse)

* Générer les certificats pour une connexion https
  * sudo apt install certbot
  * sudo certbot certonly --standalone -d ...
  * nano harbor.yml ...
  * ...

---

NOTE: 😉 Ce laboratoire est un pré-requis à l'épreuve synthèse du cours

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2026*  
*Version 2026.04.21.2*  
*Site par [ve2cuy](https://ve2cuy.com)*