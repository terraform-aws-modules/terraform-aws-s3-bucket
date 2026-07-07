locals {
  bucket_name = "s3-files-${random_pet.this.id}"

  tags = {
    Example   = "s3-files"
    AccountId = data.aws_caller_identity.this.account_id
  }
}

provider "aws" {
  region = var.region

  # Make it faster by skipping something
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
}

data "aws_caller_identity" "this" {}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_pet" "this" {
  length = 2
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "s3-files-example-vpc"
  cidr = "10.42.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = ["10.42.1.0/24", "10.42.2.0/24"]

  tags = local.tags
}

resource "aws_security_group" "s3_files" {
  name_prefix = "s3-files-example-"
  description = "Security group for S3 Files mount targets"
  vpc_id      = module.vpc.vpc_id

  # Allow NFS traffic from within the VPC so that clients can mount the
  # file system.  Without this rule mount targets are unreachable even
  # though the Terraform apply succeeds.
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, {
    Name = "s3-files-example-sg"
  })
}

data "aws_iam_policy_document" "s3_files_assume_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["elasticfilesystem.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_files" {
  name_prefix        = "s3-files-example-"
  assume_role_policy = data.aws_iam_policy_document.s3_files_assume_role.json

  tags = local.tags
}

module "s3_bucket" {
  source = "../../"

  bucket = local.bucket_name

  force_destroy = true

  versioning = {
    enabled = true
  }

  tags = local.tags
}

data "aws_iam_policy_document" "s3_files_bucket_access" {
  statement {
    sid    = "AllowBucketListing"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]

    resources = [module.s3_bucket.s3_bucket_arn]
  }

  statement {
    sid    = "AllowObjectReadWrite"
    effect = "Allow"

    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:PutObject"
    ]

    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]
  }
}

resource "aws_iam_role_policy" "s3_files_bucket_access" {
  name   = "s3-files-bucket-access"
  role   = aws_iam_role.s3_files.id
  policy = data.aws_iam_policy_document.s3_files_bucket_access.json
}

module "s3_files" {
  source = "../../modules/s3-files"

  bucket_arn = module.s3_bucket.s3_bucket_arn

  role_arn = aws_iam_role.s3_files.arn

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  security_group_ids = [aws_security_group.s3_files.id]

  access_points = {
    "test-app-ap" = {
      posix_user = {
        uid = 1000
        gid = 1000
      }
      root_directory = {
        path = "/test-app-data"
        creation_permissions = {
          owner_uid   = 1000
          owner_gid   = 1000
          permissions = "0755"
        }
      }
    }
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy.s3_files_bucket_access,
    module.s3_bucket
  ]
}
