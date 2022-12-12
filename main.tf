
resource "random_uuid" "uuid" {
}

resource "random_uuid" "uuid2" {
}

## Create GCS Bucket for Data files
resource "google_storage_bucket" "gcs_bucket" {
  name          = "rkc-data-fusion-poc-${random_uuid.uuid.result}"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }
}


## Copy data files to GCS
resource "google_storage_bucket_object" "sample-data" {
  name   = "electronic-card-transactions-october-2022-csv-tables.csv"
  source = "/home/rkchatti/Data_Fusion/Data/electronic-card-transactions-october-2022-csv-tables.csv"
  bucket = "${google_storage_bucket.gcs_bucket.name}"

  depends_on = [google_storage_bucket.gcs_bucket]
}


## Create BQ Dataset
resource "google_bigquery_dataset" "dataset_1" {
  dataset_id                  = "data_fusion_out"
  friendly_name               = "rkcfirstdataset"
  description                 = "This is a test description"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }

#   access {
#     role          = "OWNER"
#     user_by_email = google_service_account.bqowner.email
#   }

#   access {
#     role   = "READER"
#     domain = "hashicorp.com"
#   }
}

resource "google_bigquery_dataset" "dataset_2" {
  dataset_id                  = "data_fusion_temp"
  friendly_name               = "rkcfirstdataset"
  description                 = "This is a test description"
  location                    = "US"
  default_table_expiration_ms = 3600000

  labels = {
    env = "default"
  }


}

## Create Table with Schema

## Create SA for Data Fusion to use with Dataproc 
resource "google_service_account" "data-fusion-sa" {
  account_id   = "data-fusion-sa-${random_uuid.uuid2.result}"
  display_name = "A service account that Jane can use"
}

# resource "google_service_account_iam_member" "admin-account-iam-1" {
#   service_account_id = google_service_account.data-fusion-sa.name
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${google_service_account.data-fusion-sa.email}"
# }

# resource "google_service_account_iam_member" "admin-account-iam-2" {
#   service_account_id = google_service_account.data-fusion-sa.name
#   role               = "roles/dataproc.worker"
#   member             = "serviceAccount:${google_service_account.data-fusion-sa.email}"
# }


## Setup a static Dataproc cluster
resource "google_dataproc_cluster" "data-fusion-dataproc-cluster" {
  name     = "data-fusion-dataproc-cluster"
  region   = "us-central1"
  graceful_decommission_timeout = "120s"
  labels = {
    foo = "bar"
  }

  cluster_config {
    # staging_bucket = "dataproc-staging-bucket"

    master_config {
      num_instances = 1
      machine_type  = "e2-medium"
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances    = 2
      machine_type     = "e2-medium"
      #min_cpu_platform = "Intel Skylake"
      disk_config {
        boot_disk_size_gb = 30
        #num_local_ssds    = 1
      }
    }

    preemptible_worker_config {
      num_instances = 0
    }

    # Override or set some custom properties
    software_config {
      image_version = "2.0.35-debian10"
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
      }
    }

    # gce_cluster_config {
    #   tags = ["foo", "bar"]
    #   # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    #   service_account = google_service_account.data-fusion-sa.email
    #   service_account_scopes = [
    #     "cloud-platform"
    #   ]
    # }

    # # You can define multiple initialization_action blocks
    # initialization_action {
    #   script      = "gs://dataproc-initialization-actions/stackdriver/stackdriver.sh"
    #   timeout_sec = 500
    # }
  }
}

## Create Data Fusion Instance
resource "google_data_fusion_instance" "data_fusion_instance" {
  name = var.instance_name
  description = var.description
  region = var.region
  type = var.cdf_version
  enable_stackdriver_logging = true
  enable_stackdriver_monitoring = true
  labels = {
    instance_owner = var.instance_owner
  }
  private_instance = true
  network_config {
    network = var.cdf_network
    ip_allocation = var.cdf_ip_range
  }
  version = var.cdf_release
  dataproc_service_account = "${google_service_account.data-fusion-sa.email}"
}

## Create a Data Fusion profile
resource "cdap_profile" "profile" {
    name  = "static-dataproc"
    label = "static-dataproc"
    profile_provisioner {
        name = "gcp-dataproc"
        properties {
            name        = var.project_id
            value       = var.project_id
            is_editable = false
        }
    }
}

## Create a new namespace
resource "cdap_namespace" "namespace0" {
    name = "Demo_Namespace"
}

## Deploy a Data Fusion pipeline
resource "cdap_application" "pipeline0" {
    name = "gcs_to_bq"
    spec = file("/home/rkchatti/Data_Fusion/Pipelines/GCS_To_BQ-cdap-data-pipeline.json")
    depends_on = [google_data_fusion_instance.data_fusion_instance]
}


## Deploy a Data Fusion pipeline, to a targeted namespace 
resource "cdap_application" "pipeline1" {
    name = "gcs_to_bq"
    spec = file("/home/rkchatti/Data_Fusion/Pipelines/GCS_To_BQ-cdap-data-pipeline.json")
    namespace = "Demo_Namespace"
    depends_on = [google_data_fusion_instance.data_fusion_instance]
}


## Deploy a Data Fusion pipeline, to a targeted namespace 
resource "cdap_application" "pipeline2" {
    name = "gcs_to_bq_2"
    spec = file("/home/rkchatti/Data_Fusion/Pipelines/GCS_To_BQ-cdap-data-pipeline.json")
    namespace = "Demo_Namespace"
    depends_on = [google_data_fusion_instance.data_fusion_instance]
}

