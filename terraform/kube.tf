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
  // depends_on = [ kubernetes_deployment.clari_app_deployment ]
  metadata {
    name = "clari-app-pv"
  }
  spec {
    capacity = {
      storage = var.pv_capacity
    }
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "clari-app-sc"
    persistent_volume_source {
      host_path {
        path = "/var/lib/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "clari_app_persistent_volume_claim" {
  depends_on = [ kubernetes_persistent_volume.clari_app_persistent_volume ]
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
    storage_class_name = "clari-app-sc"
  }
}

resource "kubernetes_service" "clari_app_service" {
  depends_on = [ kubernetes_deployment.clari_app_deployment ]
  metadata {
    name = "clari-app-service"
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
    depends_on = [ kubernetes_daemonset.clari_app_daemonset ]
    metadata {
        name = "clari-app-deployment"
        labels = {
            app = "clari-app-deployment"
        }   
    }

    spec {
        replicas = 3

        selector {
            match_labels = {
                name = "clari-app-deployment"
            }
        }

        template {
            metadata {
                labels = {
                    name = "clari-app-deployment"
                }
            }
        
            spec {
                container {
                    name  = "clari-app"
                    image = var.app_image
                    // uncomment it when using gpu
                    # resources {
                    #     requests = {
                    #         "nvidia/gpu" = "1"
                    #     }
                    #     limits = {
                    #         "nvidia/gpu" = "1"
                    #     }
                    # }

                    volume_mount {
                        name      = "config-volume"
                        mount_path = "/var/lib/config/conf.txt"
                    }

                    volume_mount {
                        name      = "secret-volume"
                        mount_path = "/var/lib/secret/sec.txt"
                    }

                    volume_mount {
                        name      = "persistent-volume"
                        mount_path = "/var/lib/data"
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
                                    key      = "ephemeral-node-pool"
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

resource "kubernetes_config_map" "daemonset_config_map" {
  metadata {
    name = "daemonset-config-map"
  }

  data = {
    "script.sh" = var.init_script
  }
}

resource "kubernetes_daemonset" "clari_app_daemonset" {
  metadata {
    name = "clari-app-daemonset"
  }

  spec {
    selector {
      match_labels = {
        app = "clari-app-daemonset"
      }
    }

    template {
      metadata {
        labels = {
          app = "clari-app-daemonset"
        }
      }

      spec {
        init_container {
          name  = "init-container"
          image = "busybox"
          command = [ "sh", "-c", "/var/lib/scripts/script.sh" ]
          volume_mount {
            name      = "config-volume"
            mount_path = "/var/lib/scripts"
          }
        }

        container {
          name = "pause"
          image = "gcr.io/google-containers/pause:2.0"
        }

        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.daemonset_config_map.metadata[0].name
          }
        }
      }
    }
  }
}
