variable "route_53_zone_id" {}

variable "record_name" {}

variable "lb_public_ip" {
  # value = "${module.network.public_ip_address}"
}