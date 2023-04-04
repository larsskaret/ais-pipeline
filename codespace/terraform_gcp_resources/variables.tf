
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

variable "gcp_key_path_terraform" {
    type = string
    description = "Path to the terraform private key"
    default = "../.secrets/gcp_terraform.json"
}

variable "user" {
  description = "User name for ssh connection to compute engine"
  default     = "ais"
  type        = string
}

variable "data_lake_bucket" {
  description = "Name for GCP data lake bucket"
  default     = "data_lake_bucket"
  type        = string
}

variable "bq_dataset" {
  description = "Name for BigQuery Dataset"
  default     = "ais_data"
  type        = string
}

variable "storage_class" {
  description = "Storage class for GCP bucket. Check official docs for more info."
  default     = "STANDARD"
  type        = string
}

#Compute variables:

variable "compute_name" {
  description = "Name of compute instance"
  default     = "ais-compute-1"
  type        = string
}


variable "compute_start_script_path" {
    type = string
    description = "Path to compute startup script"
    default= "../../compute_engine/init_compute_engine.sh"
}

variable "compute_ssh_loc" {
  type    = string
  default = ".ssh/google_compute_engine"
}

variable "compute_status" {
  description = "Status: RUNNING or TERMINATED"
  default     = "RUNNING"
  type        = string
}