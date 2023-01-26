
resource "google_cloudfunctions_function" "data_fusion_function" {
  project     = var.project_id
  region      = var.region

  name        = "function-test"
  description = "My function"
  runtime     = "python39"

  available_memory_mb   = 128
  entry_point           = "py_entry"

  source_archive_bucket = google_storage_bucket.storage_cfunctions.name
  source_archive_object = google_storage_bucket_object.cfunctions_src["trig_data_fusion"].name
  
  event_trigger {
      event_type = "google.pubsub.topic.publish"
      resource   = google_pubsub_topic.df_trigger.id
  }

}