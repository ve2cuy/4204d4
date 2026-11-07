# ---------------------------------------------------------------------------
# Fichier:     main.tf
# Auteur:      Alain Boudreault
# Date:        2026.11.07
# Description: Amas GKE zonal du laboratoire, créé et détruit à la demande :
#                tofu apply    (environ 8 minutes)
#                tofu destroy  (environ 5 minutes)
# ---------------------------------------------------------------------------
locals {
  etiquettes = {
    cours    = "4204d4"
    etudiant = var.etudiant
    expire   = var.expire
  }
}

resource "google_container_cluster" "labo" {
  name     = "labo-${var.etudiant}"
  location = var.zone

  # Pas de groupe de nœuds par défaut (ni initial_node_count ni node_config ici) :
  # les nœuds viennent du groupe « noeuds » ci-dessous

  # Sans cette ligne, « tofu destroy » refuse de supprimer l'amas
  deletion_protection = false

  release_channel {
    channel = "REGULAR"
  }

  resource_labels = local.etiquettes
}

resource "google_container_node_pool" "noeuds" {
  name       = "noeuds"
  cluster    = google_container_cluster.labo.id
  location   = var.zone
  node_count = var.nb_noeuds

  node_config {
    machine_type    = var.type_machine
    spot            = var.spot
    disk_type       = "pd-standard"
    disk_size_gb    = 30
    labels          = local.etiquettes
    resource_labels = local.etiquettes
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
