Intro au CLI de Docker

```bash

    $ docker --help
    $ docker commande --help

    $ docker info
    $ docker container ls
    $ docker ps
    $ docker ps -a

    $ d image pull hello-world
    $ d search cowsay

    $ d pull lherrera/cowsay
    $ docker image

    $ docker run hello-world
    $ docker run IMAGE-ID-COWSAY(47) 'Bonjour le monde!'

    $ docker image rm 47 
        Error response from daemon: conflict: unable to delete 47e12946765b (must be forced) - image is being used by stopped container f98b4071e2c3
        $ docker ps -a
        $ docker rm f98
        $ docker image rm 47
        Note: docker rmi -f 47
        
    ---

    $ docker run --name yo alpine (télécharge, exécute et quitte)
    $ docker run -it alpine :  mkdir, touch, vi test, exit
    $ dp, dpp
    $ d restart alpine, dp
    $ d run --name yo -itd alpine
    $ d attach yo, exit, dp
    $ d exec -it alpine /bin/sh, exit, dp
        $ d stop alpine
    $ d rename yo yoyo, dpp    
    $ d rm c9 92 ef ad, dpp

---

    Port IP

    $ docker search nginx
    $ docker pull nginx:latest, di
    $ dr nginx, la console est bloquée par le log du serveur web
        Tester dans un fureteur, pas de résultat
    $ CTRL+C 
    $ d logs CONT_ID 
    $ dr -it -d -p 8080:80 --name web nginx
         Tester dans un fureteur, pas de résultat
    $ d exec -it web bash
        $ nano?, apt install nano, apt update, apt install nano
        Éditer /usr/share/nginx/html/index.html     

---
    Images alainboudreault
    
        $ d  search alainboudreault
        $ dr alainboudreault/bonjour-420
        $ d image inspect alainboudreault/bonjour-420
               --> "Cmd": ["/bin/yo"],
        $ d run -it --name bonjour alainboudreault/bonjour-420 bash
            /# yo
            /# ls
            /# apt install nano
            /# nano bonjour.cpp
            /# gcc bonjour.cpp -o bonjour
            /# mv bonjour /bin/yo
            /# exit
        $ d exec bonjour /bin/yo
        # produire une image avec la nouvelle version
        $ docker commit bonjour bonjour
        $ di
        $ d run bonjour  # l'app bonjour ne roule pas!
        $ d inspect bonjour -> "Cmd": ["bash"]
        $ docker commit --change='CMD ["/bin/yo"]' bonjour:v2
        $ dr bonjour:v2

        Faire labo 3.6 de http://ve2cuy.com/420-4d4b/index.php/docker-introduction/
            Extra, créer une nouvelle image 'image-web' à partir du résultat final et tester.

---

$ docker inspect serveur-web 

$ docker inspect serveur-web | grep  "IPAddress"
    "IPAddress": "172.17.0.3",

 $ inspect serveur-web | grep  "Image"
    "Image": "sha256:325b00a35073d9aa1d3df16da8afbbae1ac7d824c505f7490cd5cdbb79d60f6d",
    "Image": "nginx:latest",

---

lzd$ docker container ls --filter "status=exited"

$ docker run -d --name "toto" --label "app=web-service" --label "environment=production" nginx:latest
$ docker container ls --filter "name=toto"
$ docker container ls --filter "label=env=production"

# Afficher les conteneurs d'image de type x
$ docker ps -a --filter ancestor=nginx

#  Afficher avec un format personnalisé :
$ docker ps --filter ancestor=nginx --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

```
