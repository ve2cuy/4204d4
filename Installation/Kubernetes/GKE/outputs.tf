# ---------------------------------------------------------------------------
# Fichier:     outputs.tf
# ---------------------------------------------------------------------------
output "amas" {
  value = google_container_cluster.labo.name
}

output "connexion" {
  description = "Commande qui ajoute l'amas au fichier ~/.kube/config"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.labo.name} --zone ${var.zone} --project ${var.projet}"
}

output "expire" {
  value = var.expire
}
