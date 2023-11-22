# resource "kubernetes_persistent_volume" "clari_app_persistent_volume" {
#   metadata {
#     name = "clari-app-pv"
#   }
#   spec {
#     capacity = {
#       storage = "2Gi"
#     }
#     access_modes = ["ReadWriteOnce"]
#     persistent_volume_source {
#       vsphere_volume {
#         volume_path = "/absolute/path"
#       }
#     }
#   }
# }

resource "kubernetes_config_map" "clari_app_config_map" {
  metadata {
    name = "clari-app-config"
  }

  data = var.config_map_data
}

resource "kubernetes_secret" "clari_app_secret" {
  metadata {
    name = "clari-app-secret"
  }

  data = var.secret_data
}

resource "kubernetes_persistent_volume" "clari_app_persistent_volume" {
  metadata {
    name = "clari-app-pv"
  }
  spec {
    capacity = {
      storage = var.pv_capacity
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      gce_persistent_disk {
        pd_name = "clari-app-pd"
        fs_type = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "clari_app_persistent_volume_claim" {
  metadata {
    name = "clari-app-pvc"
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.pv_claim_capacity
      }
    }
  }
}

resource "kubernetes_service" "example" {
  metadata {
    name = "terraform-example"
  }
  spec {
    selector = {
      app = kubernetes_deployment.clari_app_deployment.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_deployment" "clari_app_deployment" {
    metadata {
        name = "clari-app-deployment"
        labels = {
            app = "clari-app"
        }   
    }

    spec {
        replicas = 3

        selector {
            match_labels = {
                name = "clari-app"
            }
        }

        template {
            metadata {
                labels = {
                    name = "clari-app"
                }
            }
        
            spec {
                container {
                    name  = "clari-app"
                    image = var.app_image
                    resources {
                        limits = {
                            nvidia.com/gpu = 1
                        }
                    }
                }

                toleration {
                    key      = "nvidia.com/gpu"
                    operator = "Equal"
                    value    = "present"
                    effect   = "NoSchedule"
                }

                affinity {
                    node_affinity {
                        required_during_scheduling_ignored_during_execution {
                            node_selector_term {
                                match_expressions {
                                    key      = "cloud.google.com/gke-spot"
                                    operator = "In"
                                    values   = ["true"]
                                }
                            }
                        }
                    }
                }
            }   
        }  
    }          
}