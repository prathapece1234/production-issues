output "vm_name" {
  description = "VM name"
  value       = google_compute_instance.vm_instance.name
}

output "vm_external_ip" {
  description = "External IP"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "firewall_name" {
  description = "Firewall rule name"
  value       = google_compute_firewall.allow_web_ssh.name
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh terraform@${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}"
}
