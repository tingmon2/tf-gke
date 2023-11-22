terraform {
    required_providers {
    }
}

provider "google" {
    credentials = var.gcp_credentials
    project = var.gcp_project_id
    region = var.gcp_region
}

provider "google-beta" {
    credentials = var.gcp_credentials
    project = var.gcp_project_id
    region = var.gcp_region
}

provider "kubernetes" {
  host = "https://${module.gke.cluster_endpoint}"  # Replace with your GKE cluster endpoint
  token = module.gke.access_token  # Replace with your service account token
  cluster_ca_certificate = base64encode(module.gke.cluster_ca_certificate)

  config_context = "gpu-cluster"
}


# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}
