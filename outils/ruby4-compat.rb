# Le Jekyll 3.9 de GitHub Pages appelle tainted? et untaint, retirées de Ruby 3.2 et plus.
# Chargé seulement par outils/apercu.sh, pour l'aperçu local.
class Object
  def tainted?; false; end
  def untaint; self; end
end
