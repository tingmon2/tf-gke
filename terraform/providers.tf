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
  // config_path = "~/.kube/config"  # Specify the path to your kubeconfig file
  config_context_auth_info = {
    cluster = "gpu-cluster"
    user = "gke-admin"
  }
}


# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}
