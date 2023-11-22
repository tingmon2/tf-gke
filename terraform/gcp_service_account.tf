// 이미 생성된 서비스 어카운트 사용

# resource "google_service_account" "gke-sa" {
#   depends_on = [google_project_service.iam]
#   account_id = var.gke_sa_name
#   display_name = "A Service Account for the Code Mental GKE Cluster"
# }


