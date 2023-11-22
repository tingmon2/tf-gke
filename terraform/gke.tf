module "gke" {
  // depends_on = [google_service_account.gke-sa, google_project_service.kubernetes, google_project_service.compute, google_project_service.iam]
  // depends_on = [google_project_service.kubernetes, google_project_service.compute, google_project_service.iam]
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  version                    = "19.0.0"
  project_id                 = var.gcp_project_id
  name                       = var.gke_cluster_name
  region                     = var.gcp_region // asia-northeast3
  regional                   = false // zonal
  ip_range_pods              = "" // auto assign
  ip_range_services          = "" // auto assign
  zones                      = var.gke_zones // asia-northeast3-a
  network                    = data.google_compute_network.vpc.name // default
  subnetwork                 = data.google_compute_subnetwork.subnet.name // default
  http_load_balancing        = true
  horizontal_pod_autoscaling = true // pod autoscaling
  network_policy             = false
  remove_default_node_pool   = true
  create_service_account = false
  logging_service = "none"

  node_pools = [
    {
      name               = var.gke_default_nodepool_name
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 1
      local_ssd_count    = 0
      disk_size_gb       = 25
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "${var.gke_sa_name}@${var.gcp_project_id}.iam.gserviceaccount.com"
      preemptible        = false
      #preemptible        = false
      initial_node_count = 1
    },
    {
      name               = "ephemeral-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 1
      local_ssd_count    = 0
      disk_size_gb       = 25
      disk_type          = "pd-standard" // standard persistent disk
      image_type         = "COS_CONTAINERD" // Container-Optimized OS with Containerd
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "${var.gke_sa_name}@${var.gcp_project_id}.iam.gserviceaccount.com"
      preemptible        = true // 24시간 짜리 스팟 인스턴스
      #preemptible        = false
    },
    {
      name               = "spot-node-pool"
      machine_type       = "e2-medium"
      min_count          = 1
      max_count          = 1
      local_ssd_count    = 0
      disk_size_gb       = 25
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      service_account    = "${var.gke_sa_name}@${var.gcp_project_id}.iam.gserviceaccount.com"
      spot               = true
    }

  ]


  node_pools_labels = {
    all = {}
     "${var.gke_default_nodepool_name}" = {
      core-node-pool = true
    }

    ephemeral-node-pool = {
      ephemeral-node-pool = true
    }

  }

  node_pools_taints = {
    all = []

    "${var.gke_default_nodepool_name}" = []
  }

}
