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

resource "google_compute_firewall" "firewall" {
  name    = "gritfy-firewall-externalssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["externalssh"]
}

resource "google_compute_firewall" "webserverrule" {
  name    = "gritfy-webserver"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }

  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["webserver"]
}

# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.project_id
  region = var.region
  depends_on = [ google_compute_firewall.firewall ]
}

resource "random_id" "id" {
	  byte_length = 8
}

resource "google_compute_resource_policy" "instance_schedule" {
  name = "schedule"
  region = var.region
  description = "Start and stop instance"


  instance_schedule_policy {
    vm_start_schedule {
      schedule = "30 5 * * *" #0/10 * * * *"#var.vm_start_schedule#"0 * * * *"
    }
    vm_stop_schedule {
      schedule = "45 6 * * *" #5/10 * * * *"#var.vm_stop_schedule#"15 * * * *"
    }
    time_zone = "Europe/Paris"
  }
}

#For creating custom service account for the compute instance - should move this
resource "google_service_account" "compute-sa" {
  project      = var.project_id
  account_id   = "compute-sa"
  display_name = "compute-sa"

}
#should move this
resource "google_project_iam_member" "service-computeiam" {
  #for_each = toset(var.sa_roles_terraform)

  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:service-814561174817@compute-system.iam.gserviceaccount.com"
  #Project number should be in env, 814561174817

}

resource "google_compute_instance" "dev" {
  name         = "devserver" # name of the server
  machine_type = "e2-standard-4" # machine type refer google machine types
  zone         = var.zone # `a` zone of the selected region in our case us-central-1a
  tags         = ["externalssh","webserver"] # selecting the vm instances with tags
  desired_status = var.compute_status
  
  resource_policies = [
    google_compute_resource_policy.instance_schedule.id
  ]



  # to create a startup disk with an Image/ISO. 
  # here we are choosing the CentOS7 image
  boot_disk { 
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230213"
      size=30
    }
  }

  # We can create our own network or use the default one like we did here
  network_interface {
    network = "default"

    # assigning the reserved public IP to this instance
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  # This is copy the the SSH public Key to enable the SSH Key based authentication
  metadata = {
    ssh-keys = "${var.user}:${file("${var.compute_ssh_loc}.pub")}"
  }

  # to connect to the instance after the creation and execute few commands for provisioning
  # here you can execute a custom Shell script or Ansible playbook

  connection {
    host        = google_compute_address.static.address
    type = "ssh"
    user = var.user
    private_key = file(var.compute_ssh_loc)
    agent = "false"
    timeout = "60s"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir ais_pipeline"
    ]
  }

  #Transfer files
  provisioner "file" {
    source = "./test/"
    destination = "./ais_pipeline"
  }

  #Provisioners is a hack that 
  provisioner "remote-exec" {
    script = "../${var.compute_start_script_path}"
  }


  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = [ google_compute_firewall.firewall, google_compute_firewall.webserverrule ]

  # Defining what service account should be used for the VM
  service_account {
    email  = "${google_service_account.compute-sa.email}"
    scopes = ["cloud-platform"]#compute-rw", "roles/compute.instanceAdmin"]
  }             
}


