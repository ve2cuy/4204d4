# ---------------------------------------------------------------------------
# Fichier:     variables.tf
# Description: Paramètres de l'amas GKE du laboratoire (valeurs dans terraform.tfvars).
# ---------------------------------------------------------------------------
variable "projet" {
  description = "Identifiant du projet Google Cloud"
  type        = string
}

variable "etudiant" {
  description = "Identifiant de l'étudiant (minuscules, chiffres, tirets) : nom de l'amas et étiquette"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.etudiant))
    error_message = "Minuscules, chiffres et tirets seulement (2 à 21 caractères), en commençant par une lettre."
  }
}

variable "region" {
  description = "Région Google Cloud (Montréal)"
  type        = string
  default     = "northamerica-northeast1"
}

variable "zone" {
  description = "Zone de l'amas : un amas zonal est couvert par le crédit gratuit de GKE"
  type        = string
  default     = "northamerica-northeast1-a"
}

variable "nb_noeuds" {
  description = "Nombre de nœuds ouvriers"
  type        = number
  default     = 3
}

variable "type_machine" {
  description = "Type de machine des nœuds"
  type        = string
  default     = "e2-medium"
}

variable "spot" {
  description = "Nœuds Spot : de 60 à 90 % moins chers, mais Google peut les reprendre à tout moment"
  type        = bool
  default     = true
}

variable "expire" {
  description = "Date d'expiration (AAAA-MM-JJ) : le nettoyage automatique supprime l'amas après cette date"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", var.expire))
    error_message = "Format AAAA-MM-JJ."
  }
}
