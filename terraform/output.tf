//Load balancer Outputs
output "elb_target_groups_arn" {
    value = aws_lb_target_group.pache-target-group.arn
}
output "elb_load_balancer_dns_name" {
  value = aws_lb.Apache-load-balancer
}

output "elastic_load_balancer_zone_id" {
  value =aws_lb.Apache-load-balancer.zone_id
}
