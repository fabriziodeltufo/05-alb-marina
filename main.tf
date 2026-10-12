# ==============================================================================
# 1. TARGET GROUP
# ==============================================================================

resource "aws_lb_target_group" "marina_tg" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ==============================================================================
# 2. AWS1-MARINA ATTACHMENT
# ==============================================================================

resource "aws_lb_target_group_attachment" "aws1_marina" {
  target_group_arn = aws_lb_target_group.marina_tg.arn
  target_id        = var.aws1_instance_id
  port             = 80
}

# ==============================================================================
# 3. AWS2-MARINA ATTACHMENT
# ==============================================================================

resource "aws_lb_target_group_attachment" "aws2_marina" {
  target_group_arn = aws_lb_target_group.marina_tg.arn
  target_id        = var.aws2_instance_id
  port             = 80
}

# ==============================================================================
# 4. APPLICATION LOAD BALANCER
# ==============================================================================

resource "aws_lb" "marina_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_ids
  subnets            = var.alb_subnet_ids

  tags = {
    Name = var.alb_name
  }
}

# ==============================================================================
# 5. HTTP LISTENER (HTTP -> HTTPS Redirect)
# ==============================================================================

resource "aws_lb_listener" "marina_http_listener" {
  load_balancer_arn = aws_lb.marina_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ==============================================================================
# 6. ACM CERTIFICATE (Certificate for aws.wewebby.com)
#
#    This is created during the FIRST terraform apply.
#    After the ALB is created, add the ACM validation CNAME to Hostinger.
# ==============================================================================

resource "aws_acm_certificate" "marina_ssl" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "${var.alb_name}-ssl"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# 7. HTTPS LISTENER
#
#    COMMENTED FOR FIRST APPLY.
#
#    The ALB must exist first so we can obtain its DNS name.
#    Then:
#      1. Add aws.wewebby.com CNAME in Hostinger
#      2. Wait for ACM certificate validation
#      3. Uncomment this block
#      4. Run terraform apply again
# ==============================================================================

# resource "aws_lb_listener" "marina_https_listener" {
#   load_balancer_arn = aws_lb.marina_alb.arn
#   port              = 443
#   protocol          = "HTTPS"
# 
#   ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#   certificate_arn = aws_acm_certificate.marina_ssl.arn
# 
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.marina_tg.arn
#   }
# }

# ==============================================================================
# 8. OUTPUTS
# ==============================================================================

output "alb_dns_name" {
  value       = aws_lb.marina_alb.dns_name
  description = "AWS DNS name of the Marina Store Application Load Balancer"
}

output "acm_validation_dns_name" {
  value = tolist(
    aws_acm_certificate.marina_ssl.domain_validation_options
  )[0].resource_record_name

  description = "CNAME name required for ACM DNS validation"
}

output "acm_validation_dns_value" {
  value = tolist(
    aws_acm_certificate.marina_ssl.domain_validation_options
  )[0].resource_record_value

  description = "CNAME value required for ACM DNS validation"
}
