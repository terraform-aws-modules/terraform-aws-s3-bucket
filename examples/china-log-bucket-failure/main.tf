provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

data "aws_availability_zones" "available" {}
data "aws_caller_identity" "current" {}

locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
  region      = "cn-north-1"
  name        = "china-alb-fail-${random_pet.this.id}"
  vpc_cidr    = "10.0.0.0/16"

  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

##################################################################
# S3 log bucket
##################################################################

resource "random_pet" "this" {
  length = 2
}

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

resource "aws_iam_role" "this" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

module "log_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  #  source = "git::https://github.com/bohnjamin/terraform-aws-s3-bucket.git?ref=add-china-regions"

  bucket        = "logs-${random_pet.this.id}"
  force_destroy = true

  control_object_ownership = true

  attach_elb_log_delivery_policy        = true
  attach_lb_log_delivery_policy         = true
  attach_access_log_delivery_policy     = true
  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  access_log_delivery_policy_source_accounts = [data.aws_caller_identity.current.account_id]
  access_log_delivery_policy_source_buckets  = ["arn:aws:s3:::${local.bucket_name}"]
}

##################################################################
# Application Load Balancer
##################################################################

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = local.name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

  access_logs = {
    bucket = module.log_bucket.s3_bucket_id
  }

  listeners = {
    ex-fixed-response = {
      port     = 89
      protocol = "HTTP"
      fixed_response = {
        content_type = "text/plain"
        message_body = "Fixed message"
        status_code  = "200"
      }
    }
  }

}

################################################################################
# Supporting resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]

}
