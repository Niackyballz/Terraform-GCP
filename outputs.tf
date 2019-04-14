output "nginx_public_ip_front" {
  //count = "${var.Count}"
  value = "${google_compute_instance.nginx-front.*.network_interface.0.access_config.0.nat_ip}"
}

output "nginx_public_ip_back" {
  value = "${google_compute_instance.nginx-back.*.network_interface.0.access_config.0.nat_ip}"
}
