###############################################
# ✅ OUTPUTS SMARTGIA
###############################################

output "region" {
  description = "AWS region in use"
  value       = var.aws_region
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnets" {
  description = "Private subnet IDs"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "bastion_public_ip" {
  description = "Public IP of bastion host (may change)"
  value       = aws_instance.bastion.public_ip
}

output "bastion_elastic_ip" {
  description = "Elastic IP of bastion host (FIXED IP)"
  value       = aws_eip.bastion_eip.public_ip
}
