# Fihier Vagrant permettant de lancer 2 VM Ubuntu sous VirtualBox



 Nom du fichier:     Vagrantfile
 
 Auteur:             Alain Boudreault
 
 Date:               2021.04.07
 
 M-A-J: 2021.04.15 - Ajout du routage des paquets IP et du DNS local


 Démarrage:          vagrant up
 
 Lister les VM:      vagrant global-status
 
 Login via vagrant:  vagrant ssh nomDeLaMachine
 
   Pour passer en mode root: sudo -s pour passer en root
 
   Pour permettre ssh:       sudo passwd vagrant

 Login direct:       ssh vagrant@ip (password=vagrant)
 
 Arrêt des VM:       vagrant halt
 
 Suppression des VM: vagrant destroy    

 https://raw.githubusercontent.com/ve2cuy/4204d4/main/module06/Vagrantfile

 Voici un exemple K8s complet: https://github.com/ansilh/k8s-vagrant

