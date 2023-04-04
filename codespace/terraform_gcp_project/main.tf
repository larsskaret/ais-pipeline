terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
 

  #https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#user_project_override
  #user_project_override = true
}


# Create the project
resource "google_project" "project" {
  name            = var.project_id
  project_id      = var.project_id
  billing_account = var.gcp_billing_id
}

# Use `gcloud` to enable:
# - serviceusage.googleapis.com
# - cloudresourcemanager.googleapis.com
resource "null_resource" "enable_service_usage_api" {
  provisioner "local-exec" {
    command = "gcloud services enable serviceusage.googleapis.com cloudresourcemanager.googleapis.com --project ${var.project_id}"
  }

  depends_on = [google_project.project]
}

#Instead of the above, I want to try:
#resource "google_project_service" "crm_api" {
#  service            = "cloudresourcemanager.googleapis.com"
#  disable_on_destroy = false
#  project            = var.project
#}


# Wait for the new configuration to propagate
# Do we need this? Test without
resource "time_sleep" "wait_project_init" {
  create_duration = "60s"

  depends_on = [null_resource.enable_service_usage_api]
}

# Enable other services used in the project
resource "google_project_service" "services" {
  for_each = toset(var.gcp_services)

  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false

  depends_on = [time_sleep.wait_project_init]
}

# Set up service accounts: terraform, prefect and dbt

#Terraform
resource "google_service_account" "sa_tf" {
  project      = var.project_id
  account_id   = var.sa_account_id_terraform
  display_name = var.sa_name_terraform

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_project_iam_member" "sa_tf_iam" {
  for_each = toset(var.sa_roles_terraform)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa_tf.email}"

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_service_account_key" "sa_key_tf" {
  service_account_id = google_service_account.sa_tf.name
}

resource "local_file" "private_key_tf" {
    content  = base64decode(google_service_account_key.sa_key_tf.private_key)
    filename = "../${var.gcp_key_path_terraform}"
}


#Prefect
resource "google_service_account" "sa_pf" {
  project      = var.project_id
  account_id   = var.sa_account_id_prefect
  display_name = var.sa_name_prefect

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_project_iam_member" "sa_pf_iam" {
  for_each = toset(var.sa_roles_prefect)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa_pf.email}"

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_service_account_key" "sa_key_pf" {
  service_account_id = google_service_account.sa_pf.name
}

resource "local_file" "private_key_pf" {
    content  = base64decode(google_service_account_key.sa_key_pf.private_key)
    filename = "../${var.gcp_key_path_prefect}"
}


#dbt
resource "google_service_account" "sa_dbt" {
  project      = var.project_id
  account_id   = var.sa_account_id_dbt
  display_name = var.sa_name_dbt

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_project_iam_member" "sa_dbt_iam" {
  for_each = toset(var.sa_roles_dbt)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.sa_dbt.email}"

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_service_account_key" "sa_key_dbt" {
  service_account_id = google_service_account.sa_dbt.name
}

resource "local_file" "private_key_dbt" {
    content  = base64decode(google_service_account_key.sa_key_dbt.private_key)
    filename = "../${var.gcp_key_path_dbt}"
}

#Compute instance
resource "google_service_account" "compute_sa" {
  project      = var.project_id
  account_id   = "compute-sa"
  display_name = "compute-sa"

}

#To allow GCP to turn on and off compute engine
resource "google_project_iam_member" "service_compute_iam" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:service-${var.gcp_project_nr}@compute-system.iam.gserviceaccount.com"
  #Project number should be in env, 814561174817

}