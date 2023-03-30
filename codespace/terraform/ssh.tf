#Generate an SSH key pair, use tls for this
provider "tls" {
  // no config needed
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "../${var.compute_ssh_loc}"
  file_permission = "0600"
}

#Create a separate network for isolation, best practices -ssh
resource "google_compute_network" "vpc_network" {
  name = "my-network"
}

resource "google_compute_address" "static_ip" {
  name = "instance-ais"
}

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

data "google_client_openid_userinfo" "me" {}