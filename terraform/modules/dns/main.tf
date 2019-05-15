resource "aws_route53_record" "www" {
  zone_id = "${var.route_53_zone_id}"
  name    = "${var.record_name}"
  type    = "A"
  ttl     = "300"
  records = ["${var.lb_public_ip}"]
}
