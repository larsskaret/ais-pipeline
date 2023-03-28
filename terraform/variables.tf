locals {
  data_lake_bucket = "ais_data_lake"
}

variable "project" {
  description = "Your GCP Project ID"
  type = string
}

variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default = "europe-west1"
  type = string
}

variable "zone" {
  default = "europe-west1-b"
  type = string
}

variable "storage_class" {
  description = "Storage class type for your bucket. Check official docs for more info."
  default = "STANDARD"
}

variable "bq_dataset" {
  description = "BigQuery Dataset"
  type = string
  default = "ais_data"
}

variable "user" {
  description = "User name for ssh connection to compute engine"
  default     = "ais"
  type        = string
}

variable "compute_status" {
  description = "Status: RUNNING or TERMINATED"
  default     = "RUNNING"
  type        = string
}