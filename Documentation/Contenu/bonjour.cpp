// Fichier: bonjour.cpp
// Exemple d'une application 'bin' pour Linux
// Par Alain Boudreault
// Fichier source compilé avec 'gcc' sous Ubuntu
// Il est possible d'avoir à installer g++ et gcc: apt install g++ gcc
#include <stdio.h>;
#define MAXITERATION 10

/**
   Incroyable mais oui, il n'y a qu'une seule fonction dans ce programme ;-)
*/
int main(){
  for (int i=1; i <= MAXITERATION; i++) {
    printf("%d\t - Bonjour 420-4D4 !!!\n", i);
  } // for i
  return 0;
} // main()