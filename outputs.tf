output "internal_ip_address_node-cp_yandex_cloud" {
  value = "${yandex_compute_instance.node-cp.network_interface.0.ip_address}"
}

output "external_ip_address_node-cp_yandex_cloud" {
  value = "${yandex_compute_instance.node-cp.network_interface.0.nat_ip_address}"
}
output "internal_ip_address_node-work-1_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-1.network_interface.0.ip_address}"
}

output "external_ip_address_node-work-1_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-1.network_interface.0.nat_ip_address}"
}
output "internal_ip_address_node-work-2_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-2.network_interface.0.ip_address}"
}

output "external_ip_address_node-work-2_yandex_cloud" {
  value = "${yandex_compute_instance.node-work-2.network_interface.0.nat_ip_address}"
}