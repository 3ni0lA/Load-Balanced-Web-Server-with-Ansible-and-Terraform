# create a record set in route 53

# terraform aws route 53 record

resource "aws_route53_record" "site_domain" {
  zone_id = aws_route53_zone.hosted_zone.zone_id
  name    = "Apache-terraform-test.${var.domain_name}"
  type    = "A" 
  
   alias {
    name                   = aws_lb.Apache-load-balancer.dns_name
    zone_id                = aws_lb.Apache-load-balancer.zone_id
    evaluate_target_health = true
  }
}
