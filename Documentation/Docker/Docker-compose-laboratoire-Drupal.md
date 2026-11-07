# 18 - Docker-Compose – Laboratoire (Drupal)

*Document converti depuis 4204d4.ve2cuy.com — 23 février 2023*

## Contenu

- [**1 – Défi**](#section-1)
- [**2 – Prescriptions**](#section-2)

---

## 1 – Défi {#section-1}

Déployer le gestionnaire de contenu ***Drupal*** à l’aide de **Docker-compose**.

[Référence](https://hub.docker.com/_/drupal)

## 2 – Prescriptions {#section-2}

* Réseau privé nommé ‘***drupal_net***‘
* Volumes, dans des dossiers de l’hôte, pour les:
  * modules
  * profiles
  * et thèmes
    * **NOTE**: Il faut copier les fichiers de ***conf*** de Drupal dans le volume principal – voir la documentation:
      *$ docker run –rm drupal tar -cC /var/www/html/sites . | tar -xC /path/on/host/sites*
* Le SGBD ***postgres***
* Port IP de l’hôte: 80

Note: Il est possible que la dernière version (TAG) de Drupal ne fonctionne pas avec l’image de base de Postgres. À vous de proposer une solution.

<https://www.digitalocean.com/community/tutorials/how-to-install-drupal-with-docker-compose>

<https://drupal-community.web.cern.ch/t/setting-up-a-local-drupal-environment-with-docker-compose/1328>

<https://gitlab.com/deviktta/docker-compose-for-drupal>

<https://wodby.com/docs/1.0/stacks/drupal/local/>

---

## Crédits

*Document rédigé par Alain Boudreault © 2021-2026*  
*Révision 2026.11.07.1*  

*Contenu par [VE2CUY](https://ve2cuy.github.io/blog/)*
