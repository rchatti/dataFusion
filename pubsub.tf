## Create Pubsub Topic
resource "google_pubsub_topic" "df_trigger" {
  name = "job-topic"
}