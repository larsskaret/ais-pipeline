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
  credentials = "../secrets/gcp_terraform.json"
}

# Data Lake Bucket
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket
resource "google_storage_bucket" "data-lake-bucket" {
  name          = "${local.data_lake_bucket}_${var.project}" # Concatenating DL bucket & Project name for unique naming
  location      = var.region

  # Optional, but recommended settings:
  storage_class = var.storage_class
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

resource "google_service_account" "compute-sa" {
  account_id = "compute-sa"
}

#ssh
resource "google_compute_address" "static_ip" {
  name = "instance-ais"
}
#ssh
resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-ssh"] // this targets our tagged VM
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
#ssh
data "google_client_openid_userinfo" "me" {}

#See also logseq!
# Enable the necessary services on the project for deployments
resource "google_project_service" "service" {
  #TODO Set what APIs to use.
  for_each = toset([
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com"

  ])

  service = each.key

  project            = var.project
  disable_on_destroy = false
}
