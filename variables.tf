variable "project_id" {
  description = "The project id of the cdf deployment"
  type        = string
}

variable "gcs_cfunctions_suffix" {
  description = "GCS Bucket suffix to use with Cloud Function source code"
  type        = string
}

variable "instance_name" {
  description = "The instance name."
  type        = string
}

variable "cdf_version" {
  description = "The version of CDF to deploy: BASIC, DEVELOPER, ENTERPRISE"
  type        = string
}

variable "cdf_release" {
  description = "The release of cdf to deploy: 6.6.x, 6.5.x, etc."
  type        = string
}

variable "cdf_network" {
  description = "The network to deploy CDF on"
  type        = string
}

variable "cdf_ip_range" {
  description = "The /22 CIDR range to deploy CDF on"
  type        = string
}

variable "description" {
  description = "The description of the instance"
  type        = string
}

variable "default_service_account" {
  description = "The default dataproc service account"
  type        = string
}

variable "region" {
  description = "The region data fusion is deployed in"
  type        = string
}

variable "instance_owner" {
  description = "The email of the instance owner"
  type        = string
}

variable "cdf_region_map" {
  description = "map"
  default = {
      "us-central1" = "usc1"
      "us-east1" = "use1"
      "us-east4" = "use4"
      "us-west1" = "usw1"
      "us-west2" = "usw2"
  }
}