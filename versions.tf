
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
  credentials = file("./sturdy-dogfish-369718-c3c49490ccca.json")
  project = "sturdy-dogfish-369718"
}

data "google_client_config" "current" {}

provider "cdap" {
  host = "${google_data_fusion_instance.create_data_fusion_instance.service_endpoint}/api/"
  token = data.google_client_config.current.access_token
}


