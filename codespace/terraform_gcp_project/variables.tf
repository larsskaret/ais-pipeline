# variable.tf is where all variables are declared; these might or might not have a default value.
# terraform.tfvars is where the variables are provided/assigned a value.
# In addition, variables can be assigned from environment varialbes if they are prefixed with TF_VAR_

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Region for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default     = "europe-west1"
  type        = string
}

variable "zone" {
  description = "Zone for GCP resources. Choose as per your location: https://cloud.google.com/about/locations"
  default     = "europe-west1-b"
  type        = string
}

variable "gcp_billing_id" {
   type = string
}

#variable "gcp_project_nr" {
#  type = string
#}

variable "gcp_services" {
  type        = list
  default     = [
    # List all the services you use here
    "bigquery.googleapis.com"
  ]
}

# Service account for terraform
variable "sa_account_id_terraform" {
  type = string
  description = "The service account ID. Changing this forces a new service account to be created."
  default = "sa-terraform"
}

variable "sa_name_terraform" {
  type = string
  description = "The display name for the service account. Can be updated without creating a new resource."
  default     = "sa-terraform"
}

variable "sa_roles_terraform" {
  type        = list(string)
  description = "The roles that will be granted to the terraform service account."
  default     = ["roles/editor"]
}

variable "gcp_key_path_terraform" {
    type = string
    description = "Path to store the terraform private key"
    default = "../.secrets/gcp_terraform.json"
}

# Service account for prefect
variable "sa_account_id_prefect" {
  type = string
  description = "The service account ID. Changing this forces a new service account to be created."
  default = "sa-prefect"
}

variable "sa_name_prefect" {
  type = string
  description = "The display name for the service account. Can be updated without creating a new resource."
  default     = "sa-prefect"
}

variable "sa_roles_prefect" {
  type        = list(string)
  description = "The roles that will be granted to the service account."
  default     = ["roles/bigquery.admin", "roles/storage.admin", "roles/storage.objectAdmin", "role/viewer"]
}

variable "gcp_key_path_prefect" {
    type = string
    description = "Path to store the prefect private key"
    default = "../.secrets/gcp_prefect.json"
}

# Service account for dbt
variable "sa_account_id_dbt" {
  type = string
  description = "The service account ID. Changing this forces a new service account to be created."
  default = "sa-dbt"
}

variable "sa_name_dbt" {
  type = string
  description = "The display name for the service account. Can be updated without creating a new resource."
  default     = "sa-dbt"
}

variable "sa_roles_dbt" {
  type        = list(string)
  description = "The roles that will be granted to the service account."
  default     = ["roles/bigquery.admin", "roles/storage.admin", "roles/storage.objectAdmin", "role/viewer"]
}

variable "gcp_key_path_dbt" {
    type = string
    description = "Path to store the dbt private key"
    default = "../.secrets/gcp_dbt.json"
}