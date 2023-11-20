output "cluster_ips" {
  #value = yandex_compute_instance.default.network_interface.0.nat_ip_address
  value = yandex_compute_instance.default[*].network_interface.0.nat_ip_address
}

output "storage_ip" {
  value = yandex_compute_instance.storage.network_interface.0.nat_ip_address
}
