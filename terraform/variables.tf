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
  default = "ais"
}