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

resource "aws_vpc" "this" {
  cidr_block           = "10.42.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "s3-files-example-vpc"
  })
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.42.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "s3-files-example-private-a"
  })
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.42.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "s3-files-example-private-b"
  })
}

resource "aws_security_group" "s3_files" {
  name_prefix = "s3-files-example-"
  description = "Security group for S3 Files mount targets"
  vpc_id      = aws_vpc.this.id

  # Allow NFS traffic from within the VPC so that clients can mount the
  # file system.  Without this rule mount targets are unreachable even
  # though the Terraform apply succeeds.
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.this.cidr_block]
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

  vpc_id = aws_vpc.this.id
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

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
