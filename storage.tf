# Storage bucket for storing Cloud Function's source code
resource "google_storage_bucket" "storage_cfunctions" {
  project     = var.project_id
  name        = "${var.project_id}-${var.gcs_cfunctions_suffix}"
  location    = var.region

  # delete bucket and contents on destroy.
  force_destroy = true
}


# ZIP all source code
data "archive_file" "src_zip"{
  for_each = toset( ["trig_data_fusion"] )

  type        = "zip"
  source_dir = "Pipelines/${each.key}"
  output_path = "Pipelines/zip/${each.key}.zip"
}

# All Cloud Function's source codes
resource "google_storage_bucket_object" "cfunctions_src" {
  for_each = toset( ["trig_data_fusion"] )

  name   = "${each.key}.zip"
  bucket = google_storage_bucket.storage_cfunctions.name
  source = "Pipelines/zip/${each.key}.zip"
}