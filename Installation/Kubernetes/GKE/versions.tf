# ---------------------------------------------------------------------------
# Fichier:     versions.tf
# Auteur:      Alain Boudreault
# Date:        2026.11.07
# Description: Versions de Terraform/OpenTofu et du fournisseur Google.
# ---------------------------------------------------------------------------
terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.10"
    }
  }
}

provider "google" {
  project = var.projet
  region  = var.region
}
