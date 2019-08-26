resource "aws_route53_record" "base" {
  zone_id = "${var.route_53_zone_id}"
  name    = "${var.record_name_base}"
  type    = "A"
  ttl     = "300"
  records = ["${var.lb_public_ip}"]
}

resource "aws_route53_record" "wild" {
  zone_id = "${var.route_53_zone_id}"
  name    = "${var.record_name_wild}"
  type    = "A"
  ttl     = "300"
  records = ["${var.lb_public_ip}"]
}
