resource "google_compute_instance" "instance_ais" {
  name         = "ais-compute-1"
  machine_type = "e2-standard-4"
  tags         = ["allow-ssh"]#ssh
  #ssh
  metadata = {
    ssh-keys = "${var.user}:${tls_private_key.ssh.public_key_openssh}"
    #original: "${split("@", data.google_client_openid_userinfo.me.email)[0]}:${tls_private_key.ssh.public_key_openssh}"

  metadata_startup_script = "${file("../compute_engine/compute_engine.sh")}"
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230213"
      size=30
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name #ssh

    access_config {
      nat_ip = google_compute_address.static_ip.address #ssh
    }
  }
  service_account {
    # Google recommends custom service accounts that have cloud-platform 
    # scope and permissions granted via IAM Roles.
    email = "${google_service_account.compute-sa.email}" #google_service_account.default.email
    scopes = ["default"] #["bigquery","compute-rw","storage-rw"]
    #It's not the compute instance that will write to bigquery etc, it is service account that is stored in JSON file, read by prefect
  }
}