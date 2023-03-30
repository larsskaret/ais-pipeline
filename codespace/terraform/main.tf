terraform {
  required_version = ">= 1.0"
  
  backend "local" {}  # Can change from "local" to "gcs" (for google) or "s3" (for aws), if you would like to preserve your tf-state online
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
  zone = var.zone
  credentials = "../${var.cred_location}"
}

resource "google_project_service" "crm_api" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
  project            = var.project
}

# Data Lake Bucket
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket

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


#See also nets
# Enable the necessary services on the project for deployments
#TODO Set what APIs to use.
#TODO Move list to .env / variables?

resource "google_project_service" "service" {
  for_each = toset([
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com"
  ])

  service            = each.key
  project            = var.project
  disable_on_destroy = false
}