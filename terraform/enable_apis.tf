
// 지금 현재 새 VPC를 생성하는게 아니기 때문에 굳이 API 가동시키면 나중에 부쉴 때 이것도 부숴서 짜증남
# resource "google_project_service" "iam" {
#   service = "iam.googleapis.com"
# }

resource "google_project_service" "cloud-resources-manager" {
  service = "cloudresourcemanager.googleapis.com"
}

# resource "google_project_service" "compute" {
#   depends_on = [google_project_service.cloud-resources-manager]
#   service = "compute.googleapis.com"
# }

# resource "google_project_service" "kubernetes" {
#   service = "container.googleapis.com"
# }

