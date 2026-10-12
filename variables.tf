variable "target_group_name" {
  type        = string
  description = "The name of the ALB target group"
  default     = "marina-store-tg"
}

variable "vpc_id" {
  type        = string
  description = "The target AWS VPC ID"
}

variable "aws1_instance_id" {
  type        = string
  description = "The ID of the first EC2 target instance (aws1-marina)"
}

variable "aws2_instance_id" {
  type        = string
  description = "The ID of the second EC2 target instance (aws2-marina)"
}

variable "alb_name" {
  type        = string
  description = "The name of the Application Load Balancer"
  default     = "marina-store-alb"
}

variable "alb_security_group_ids" {
  type        = list(string)
  description = "List of Security Group IDs associated with the ALB"
}

variable "alb_subnet_ids" {
  type        = list(string)
  description = "List of public Subnet IDs for the ALB deployment"
}

variable "domain_name" {
  type        = string
  description = "The target domain name for the ACM SSL certificate"
  default     = "://wewebby.com"
}



