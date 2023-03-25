output "public_ip" {
  value = google_compute_address.static_ip.address
}

output "user" {
  value = var.user
}