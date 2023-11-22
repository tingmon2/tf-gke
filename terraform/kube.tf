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
      host_path {
        path = "/data"
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

                    volume_mount {
                        name      = "config-volume"
                        mount_path = "/etc/nginx/config"
                    }

                    volume_mount {
                        name      = "secret-volume"
                        mount_path = "/etc/nginx/secret"
                    }

                    volume_mount {
                        name      = "persistent-volume"
                        mount_path = "/etc/nginx"  # Adjust the mount path as needed in your application
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

                volume {
                    name = "config-volume"
                    config_map {
                        name = kubernetes_config_map.clari_app_config_map.metadata[0].name
                    }
                }

                volume {
                    name = "secret-volume"
                    secret {
                        secret_name = kubernetes_secret.clari_app_secret.metadata[0].name
                    }
                }

                volume {
                    name = "persistent-volume"
                    persistent_volume_claim {
                        claim_name = kubernetes_persistent_volume_claim.clari_app_persistent_volume_claim.metadata[0].name
                    }
                }
            }   
        }  
    }          
}
