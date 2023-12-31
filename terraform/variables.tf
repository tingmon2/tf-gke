// GKE cluster variables
variable "gcp_credentials" {
    type = string
    description = "Location of service account for GCP"
    default = "../../gcp-infrastructure/terraform/creds/gcp-service-account.json"
}

variable "gcp_project_id" {
    type = string
    description ="GCP Project id"
}

variable "gcp_region" {
    type = string
    description = "GCP Region"
}

variable "gcp_zone" {
    type = string
    description = "GCP Zone"
}

variable "gke_regional" {
    default = false
    description = "GCP Region"
}

variable "gke_cluster_name" {
    type = string
    description = "GKE Cluster name"
}

variable "gke_zones" {
    type = list(string)
    description = "List of zones for the GKE Cluster"
}

variable "gke_network" {
    type = string
    description = "VPC Network name"
}

variable "gke_subnetwork" {
    type = string
    description = "VPC Sub Network name"
}

variable "gke_default_nodepool_name" {
  type = string
  description = "GKE Default node pool name"
}

variable "gke_sa_name" {
  type = string
  description = "GKE Service Account Name"
}

// Kubernetes variables
variable "config_map_data" {
  description = "Data for the ConfigMap"
}

variable "secret_data" {
  description = "Data for the Secret"
}

variable "pv_capacity" {
  description = "Capacity of the Persistent Volume"
}

variable "pv_claim_capacity" {
  description = "Capacity of the Persistent Volume Claim"
}

variable "app_image" {
  description = "Docker image for the 'clari-app' application"
}

variable "init_script" {
  description = "Init script content for the DaemonSet init container"
  type        = string
}