resource "google_service_account" "cf_data_fusion_sa" {
  account_id   = "cf-data-fusion-sa-${random_string.uuid2.result}"
  display_name = "A service account that Cloud Function will use to trigger Data Fusion jobs"
}

# resource "google_data_fusion_instance_iam_member" "member" {
#   project = google_data_fusion_instance.basic_instance.project
#   region = google_data_fusion_instance.basic_instance.region
#   name = google_data_fusion_instance.basic_instance.name
#   role = "roles/viewer"
#   member = "user:jane@example.com"
# }
