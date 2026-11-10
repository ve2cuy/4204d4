#!/bin/bash
# =========================================================================
# verifier-poste.sh : vérifie la configuration Windows 11 + WSL + VirtualBox
#                     + Vagrant du document 33 (à lancer dans WSL)
# Usage : bash verifier-poste.sh
# Auteur : Alain Boudreault (VE2CUY), 2026.11.09
# =========================================================================

OK=0; PB=0
ok()  { echo "  [OK]  $*"; OK=$((OK+1)); }
pb()  { echo "  [!!]  $*"; PB=$((PB+1)); }
info(){ echo "        $*"; }

echo ">>> 1. WSL"
if grep -qi microsoft /proc/version; then ok "Ce terminal est bien dans WSL"; else pb "Ce script doit être lancé dans WSL (Ubuntu)"; exit 1; fi

if mount | grep " /mnt/c " | grep -q metadata; then
  ok "Disque C: monté avec l'option metadata"
else
  pb "Disque C: monté sans metadata : vagrant ssh demandera un mot de passe (section 3.5)"
fi

if [ "$(wslinfo --networking-mode 2>/dev/null)" = "mirrored" ]; then
  ok "Réseau de WSL en mode miroir"
else
  pb "Réseau de WSL en NAT : Vagrant ne joindra pas les VM (section 3.4)"
fi

echo ">>> 2. VirtualBox (Windows)"
VBM="/mnt/c/Program Files/Oracle/VirtualBox/VBoxManage.exe"
if [ -x "$VBM" ]; then
  ok "VirtualBox $("$VBM" --version | tr -d '\r')"
  if command -v VBoxManage.exe >/dev/null; then ok "VBoxManage.exe dans le PATH"
  else pb "VBoxManage.exe absent du PATH (section 3.7)"; fi
  INACC=$("$VBM" list vms | grep -c '"<inaccessible>"')
  if [ "$INACC" -eq 0 ]; then ok "Aucune VM inaccessible dans VirtualBox"
  else pb "$INACC VM <inaccessible> dans VirtualBox : vagrant up échouera (section 9.2)"; fi
else
  pb "VirtualBox introuvable sous Windows (section 3.2)"
fi

echo ">>> 3. Vagrant"
VW="/mnt/c/Program Files/Vagrant/bin/vagrant.exe"
if command -v vagrant >/dev/null; then
  V_WSL=$(vagrant --version 2>/dev/null | awk '{print $2}')
  ok "Vagrant $V_WSL dans WSL"
else
  pb "Vagrant absent de WSL (section 3.6)"
fi
if [ -x "$VW" ]; then
  V_WIN=$("$VW" --version 2>/dev/null | tr -d '\r' | awk '{print $2}')
  ok "Vagrant $V_WIN sous Windows"
  if [ -n "$V_WSL" ] && [ "$V_WSL" = "$V_WIN" ]; then ok "Même version des deux côtés"
  else pb "Versions différentes (WSL $V_WSL, Windows $V_WIN) : vagrant refusera de démarrer (section 9.1)"; fi
else
  pb "Vagrant introuvable sous Windows (section 3.3)"
fi

echo ">>> 4. Variables d'environnement"
if [ "$VAGRANT_WSL_ENABLE_WINDOWS_ACCESS" = "1" ]; then ok "VAGRANT_WSL_ENABLE_WINDOWS_ACCESS=1"
else pb "VAGRANT_WSL_ENABLE_WINDOWS_ACCESS n'est pas à 1 (section 3.7)"; fi

echo ">>> 5. Dossier courant"
WINHOME=$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")
case "$PWD/" in
  "$WINHOME"/*) ok "$PWD est dans le dossier Windows de l'usager ($WINHOME)" ;;
  *) pb "$PWD n'est pas sous $WINHOME : y placer les projets Vagrant (section 3.8)" ;;
esac

echo
echo ">>> Résultat : $OK vérification(s) réussie(s), $PB problème(s)"
[ "$PB" -eq 0 ] && echo ">>> Le poste est prêt : vagrant up" || echo ">>> Corriger les points [!!], puis relancer ce script"
exit "$PB"
