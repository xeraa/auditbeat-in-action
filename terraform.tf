terraform {
  required_providers {
    ec = {
      source  = "elastic/ec"
    }
  }
}


provider "aws" {
    # Credentials are defined in the environment variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
    region = var.region
}


# Create the SSH key pair
resource "aws_lightsail_key_pair" "security_key_pair" {
  name       = "security_key_pair"
  public_key = file("~/.ssh/id_rsa.pub")
}


# Create the instance, open ports, and its DNS entries
resource "aws_lightsail_instance" "security_instance" {
  name              = "security_instance"
  availability_zone = "${var.region}a"
  blueprint_id      = var.operating_system
  bundle_id         = var.size
  key_pair_name     = "security_key_pair"
  depends_on        = [aws_lightsail_key_pair.security_key_pair]
}
resource "aws_lightsail_instance_public_ports" "security_ports" {
  instance_name = aws_lightsail_instance.security_instance.name
  # SSH (defaults are overwritten so this must be specified)
  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
  # So Let's Encrypt can generate its certificate
  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }
  # HTTPS
  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
  # Port to play with nc
  port_info {
    protocol  = "tcp"
    from_port = 1025
    to_port   = 1025
  }
}
resource "aws_route53_record" "apex" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"
  ttl     = "60"
  records = [aws_lightsail_instance.security_instance.public_ip_address]
}
resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "www.${var.domain}"
  type    = "A"
  alias {
    name                   = var.domain
    zone_id                = var.zone_id
    evaluate_target_health = false
  }
  depends_on = [aws_route53_record.apex]
}


# Create the Elastic Cloud setup
resource "ec_deployment" "ec_auditbeat" {
  name                   = "auditbeat-in-action"
  region                 = var.region
  version                = "7.13.1"
  deployment_template_id = "aws-io-optimized-v2"

  elasticsearch {}

  kibana {}
}
output "elasticsearch_https_endpoint" {
  value = ec_deployment.ec_auditbeat.elasticsearch[0].https_endpoint
}
output "elastic_username" {
  value = ec_deployment.ec_auditbeat.elasticsearch_username
}
output "elastic_password" {
  value = ec_deployment.ec_auditbeat.elasticsearch_password
  sensitive = true
}
output "elasticsearch_cloud_id" {
  value = ec_deployment.ec_auditbeat.elasticsearch[0].cloud_id
}
output "kibana_https_endpoint" {
  value = ec_deployment.ec_auditbeat.kibana[0].https_endpoint
}
locals {
  elastic-cloud = <<-EOT
elasticsearch_password: ${ec_deployment.ec_auditbeat.elasticsearch_password}
elasticsearch_host: ${ec_deployment.ec_auditbeat.elasticsearch[0].https_endpoint}
elasticsearch_user: ${ec_deployment.ec_auditbeat.elasticsearch_username}
kibana_host: ${ec_deployment.ec_auditbeat.kibana[0].https_endpoint}
elastic_version: ${ec_deployment.ec_auditbeat.version}
  EOT
}

resource "local_file" "elastic_cloud_config" {
  filename = "elastic-cloud.yml"
  content  = local.elastic-cloud
}
