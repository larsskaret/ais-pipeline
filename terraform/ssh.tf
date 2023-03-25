#Should consider splitting the files
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
  filename        = ".ssh/google_compute_engine"
  file_permission = "0600"
}

#Create a separate network for isolation, best practices -ssh
resource "google_compute_network" "vpc_network" {
  name = "my-network"
}