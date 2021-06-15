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
resource "aws_route53_record" "kibana" {
  zone_id = var.zone_id
  name    = "kibana.${var.domain}"
  type    = "A"
  alias {
    name                   = var.domain
    zone_id                = var.zone_id
    evaluate_target_health = false
  }
  depends_on = [aws_route53_record.apex]
}
resource "aws_route53_record" "dashboard" {
  zone_id = var.zone_id
  name    = "dashboard.${var.domain}"
  type    = "A"
  alias {
    name                   = var.domain
    zone_id                = var.zone_id
    evaluate_target_health = false
  }
  depends_on = [aws_route53_record.apex]
}
