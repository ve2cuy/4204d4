# À partir d'une image
FROM ubuntu

# Optionnel
LABEL maintainer="Alain Boudreault <aboudrea@cstj.qc.ca>"

# Exécuter des commandes dans l'image
RUN apt-get update

ADD hello.sh /
RUN chmod a+x /hello.sh

# Commande à exécuter au démarrage d'un conteneur
CMD ["/hello.sh"]