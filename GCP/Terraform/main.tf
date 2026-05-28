terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.parent_project_id
  region      = var.region
}

# Enable required APIs
resource "google_project_service" "enabled_services" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])

  project = var.parent_project_id
  service = each.key

  disable_on_destroy = false
}

# Firewall rule to allow SSH, HTTP, HTTPS
resource "google_compute_firewall" "allow_web_ssh" {
  depends_on = [google_project_service.enabled_services]

  project = var.parent_project_id
  name    = "allow-web-ssh-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create VM
resource "google_compute_instance" "vm_instance" {
  depends_on = [google_project_service.enabled_services]

  project      = var.parent_project_id
  name         = "terraform-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "terraform:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["web", "ssh"]
}
