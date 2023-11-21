# resource "google_compute_network" "vpc" {
#   name                    = "codemental-vpc"
#   auto_create_subnetworks = "false"
# }

# resource "google_compute_subnetwork" "subnet" {
#   name          = var.gke_subnetwork
#   region        = var.gcp_region
#   network       = google_compute_network.vpc.name
#   ip_cidr_range = "10.10.0.0/24"
# }

data "google_compute_network" "vpc" {
  name    = var.gke_network
  project = var.gcp_project_id
}

data "google_compute_subnetwork" "subnet" {
  name    = var.gke_subnetwork
  project = var.gcp_project_id
  region  = var.gcp_region
}