
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.22.0"
    }
    cdap = {
      source = "GoogleCloudPlatform/cdap"
      # Pin to a specific version as 0.x releases are not guaranteed to be backwards compatible.
      version = "0.10.0"
    }
  }
}

provider "google" {
  credentials = file("./credentials/charismatic-tea-371420-47df5ed2e73b.json")
  project = var.project_id
}

data "google_client_config" "current" {}

provider "cdap" {
  host = "${google_data_fusion_instance.data_fusion_instance.service_endpoint}/api/"
  token = data.google_client_config.current.access_token
}


