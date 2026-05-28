variable "credentials_file" {
  description = "Path to the service account key JSON file"
  type        = string
}

variable "parent_project_id" {
  description = "Existing GCP project ID (where resources will be created)"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}
