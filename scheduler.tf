## Create a Cloud Scheduler with Pub/Sub target
resource "google_cloud_scheduler_job" "df_schedule" {
  name        = "df_schedule"
  description = "df_schedule"
  schedule    = "*/2 * * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.df_trigger.id
    data       = base64encode("test")
  }
}