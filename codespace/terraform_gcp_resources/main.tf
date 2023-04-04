terraform {
  required_version = ">= 1.0"
  
  backend "local" {}  # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source  = "hashicorp/google"

    }
  }
}

provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
  credentials = "../${var.gcp_key_path_terraform}"
}

resource "google_storage_bucket" "data-lake-bucket" {
  name     = var.data_lake_bucket
  location = var.region

  # Optional, but recommended settings:
  storage_class               = var.storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled     = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 60  // days
    }
  }
  force_destroy = true
}

# DWH
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset

resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.bq_dataset
  project    = var.project
  location   = var.region
}
