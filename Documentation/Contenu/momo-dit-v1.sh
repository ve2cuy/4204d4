#!/bin/sh
# Afficher à l'écran le contenu de la variable $1

if [ -z "$1" ]
then
  echo "Usage: momo-dit-v1 'un message'"
  exit 1
fi
echo "-----------------------------------------------------"
echo "Momo dit: " $1
echo "-----------------------------------------------------"
echo