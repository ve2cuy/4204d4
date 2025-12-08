# Semaine 01 - Au menu

### 1 - Présentation du cours

- Survole de Docker et Kubernetes

---

### 2 - Installation d'Ubuntu Desktop (version minimale) sur VmWare PRO
- VM nommée Ubuntu-Master
- Network connection: Bridged

NOTE: Vérifier que la bonne carte réseau est renseignée dans les paramètres de VMware
- Menu: edit -> Virtual Network Editor --> Change settings --> VMNet0 ...

### 3 - Installation de openssh-server et de firefox
NOTE: Terminal = Ctl+Alt+T

```bash
$ sudo apt update && sudo apt upgrade -y
$ sudo install openssh-server firefox -y
```
### 4 - Du poste de travail, générer une paire de clés ssh
```bash
$ ssh-keygen -C UserName
```
#### 4.1 - Copier la clé publique vers la VM
```bash
$ ssh-copy-id -i nom-du-fichier.pub userName@adresse-ip
```
#### 4.2 Renseigner une référence dans le fichier ~/.ssh/config
```bash
Au besoin: 
chmod 600 ~/.ssh/config
Host labo
# Host srv*
    HostName 'adresse-IP'
    User UserName
    Port 22
    IdentityFile ~/.ssh/uneCle
```

### 5 - Fermer et cloner la machine
- Create a linked clone: nommé 'labo'

### 6 - Démarrer et login sur 'labo'
### 7 - Éditer les fichiers /etc/hostname et /etc/hosts et corriger la référence au nom machine.

### 8 - Redémarrer la VM
```bash
$ sudo reboot
```

### 9 - ssh sur la VM 'lobo'

### 10 - Installer Docker

Voir le document : [Installation de Docker](/Installation/Docker/Installation%20de%20Docker.md)

### 11 - Tester Docker
```bash
$ docker version
$ docker help
```
---
### Facultatif : liquidPrompt:
https://liquidprompt.readthedocs.io/en/stable/overview.html
```bash
$ git clone --branch stable https://github.com/liquidprompt/liquidprompt.git ~/liquidprompt
$ source ~/liquidprompt/liquidprompt
$ source ~/liquidprompt/themes/unfold/unfold.theme
$ lp_theme unfold # lp_theme default
$ source ~/liquidprompt/themes/powerline/powerline.theme
$ lp_theme --list
```
--> Ajouter dans le fichier .bashrc :
```bash
$ nano .bashrc
[[ $- = *i* ]] && source ~/liquidprompt/liquidprompt

source ~/liquidprompt/themes/unfold/unfold.theme
source ~/liquidprompt/themes/powerline/powerline.theme
lp_theme unfold # lp_theme default
lp_theme --list
echo -e "\nPour changer de thème: lp_theme nom-du-theme\n\n"
```
---

### Ajouter des alias dan le fichier ~/.bash_aliases

Voir les [copier/coller](Documentation/Copier%2Bcoller.md)

 