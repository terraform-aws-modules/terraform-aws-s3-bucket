provider "aws" {
  region = local.region

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
  region      = "eu-west-1"
}

data "aws_canonical_user_id" "current" {}

data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

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

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.this.arn]
    }

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }
}
#
#module "log_bucket" {
#  source = "../../"
#
#  bucket                                = "logs-${random_pet.this.id}"
#  acl                                   = "log-delivery-write"
#  force_destroy                         = true
#  attach_elb_log_delivery_policy        = true
#  attach_lb_log_delivery_policy         = true
#  attach_deny_insecure_transport_policy = true
#  attach_require_latest_tls_policy      = true
#
##  logging = {
##    target_bucket = "fixtures"
##    target_prefix = "log/"
##  }
#
#}

module "s3_bucket" {
  source = "../../"

  bucket = "cloudfront-logs-${random_pet.this.id}"
  #  acl    = "private" # "public-read" # null # conflicts with default of `acl = "private"` so set to null to use grants
  #  grant = [{
  #    type        = "CanonicalUser"
  ##    permissions = ["FULL_CONTROL"]
  #    permission = "FULL_CONTROL"  # @doc - from list to string
  #    id          = data.aws_canonical_user_id.current.id
  #    }, {
  #    type        = "CanonicalUser"
  #    permission = "FULL_CONTROL"
  #    id          = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
  ##     Ref. https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
  #  }
  #  ]
  #  owner = {
  #    id = "457414f555e45c2e6fe1069d1a527a90d6337e1acb012ba99f3833859b23d338"
  ##    display_name = null #y"my account"
  #  }

  #  expected_bucket_owner = 123456781234

  #
  #    website = {
  #      #      redirect_all_requests_to = {
  #      #        host_name = "https://modules.tf"
  #      #      }
  #      index_document = "index_new.html"
  #      error_document = "error_new.html"
  #      routing_rules = [{
  #        condition = {
  #          key_prefix_equals = "docs/"
  #        },
  #        redirect = {
  #          replace_key_prefix_with = "documents/"
  #        }
  #      }, {
  #        condition = {
  #          http_error_code_returned_equals = 404
  #          key_prefix_equals = "archive/"
  #        },
  #        redirect = {
  #          host_name               = "archive.myhost.com"
  #          http_redirect_code      = 301
  #          protocol                = "https"
  #          replace_key_with = "not_found.html"
  #        }
  #      }]
  #    }

  #    versioning = {
  #      status = false
  #      mfa_delete = true #"DisableD"
  #    }

  #    server_side_encryption_configuration = {
  #      rule = {
  #        apply_server_side_encryption_by_default = {
  #          kms_master_key_id = aws_kms_key.objects.arn
  #          sse_algorithm     = "aws:kms"
  #        }
  #      }
  #    }

  #  acceleration_status = "Suspended"
  #  request_payer = "BucketOwner"

  #
  #    cors_rule = [
  #      {
  #        allowed_methods = ["PUT", "POST"]
  #        allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
  #        allowed_headers = ["*"]
  #        expose_headers  = ["ETag"]
  #        max_age_seconds = 3000
  #        }, {
  #        allowed_methods = ["PUT"]
  #        allowed_origins = ["https://example.com"]
  #        allowed_headers = ["*"]
  #        expose_headers  = ["ETag"]
  #        max_age_seconds = 3000
  #      }
  #    ]


  #    lifecycle_rule = [
  #      {
  #        id      = "log"
  #        enabled = true
  #
  #        filter = {
  ##          prefix = ""
  ##          object_size_greater_than = 200000
  ##          object_size_less_than = 500000
  #          tags = {
  #            some = "value"
  #            another = "value2"
  #          }
  #        }
  #
  #        transition = [
  #          {
  #            days          = 30
  #            storage_class = "ONEZONE_IA"
  #            }, {
  #            days          = 60
  #            storage_class = "GLACIER"
  #          }
  #        ]
  #
  ##        expiration = {
  ##          days = 90
  ##          expired_object_delete_marker = true
  ##        }
  #
  ##        noncurrent_version_expiration = {
  ##          newer_noncurrent_versions = 5
  ##          days = 30
  ##        }
  #      },
  #      {
  #        id                                     = "log1"
  #        enabled                                = true
  #        abort_incomplete_multipart_upload_days = 7
  ##
  ##        filter = {
  ##          prefix                                 = "log1/"
  ##          object_size_greater_than = 200000
  ##          object_size_less_than = 500000
  ##          tags = {
  ##            some = "value"
  ##            another = "value2"
  ##          }
  ##        }
  #
  #        noncurrent_version_transition = [
  #          {
  #            days          = 30
  #            storage_class = "STANDARD_IA"
  #          },
  #          {
  #            days          = 60
  #            storage_class = "ONEZONE_IA"
  #          },
  #          {
  #            days          = 90
  #            storage_class = "GLACIER"
  #          },
  #        ]
  #
  #        noncurrent_version_expiration = {
  #          days = 300
  #        }
  #      },
  #      {
  #        id                                     = "log2"
  #        enabled                                = true
  #
  ##        filter = {
  ##          prefix                                 = "log1/"
  ##          object_size_greater_than = 200000
  ##          object_size_less_than = 500000
  ##          tags = {
  ##            some = "value"
  ##            another = "value2"
  ##          }
  ##        }
  #
  #        noncurrent_version_transition = [
  #          {
  #            days          = 30
  #            storage_class = "STANDARD_IA"
  #          },
  #        ]
  #
  #        noncurrent_version_expiration = {
  #          days = 300
  #        }
  #      },
  #    ]

  #  object_lock_configuration = {
  #        object_lock_enabled = "Enabled"
  #        rule = {
  #          default_retention = {
  #            mode = "GOVERNANCE"
  #            days = 2
  #          }
  #        }
  #      }

  force_destroy = true
}

#module "s3_bucket" {
#  source = "../../"
#
#  bucket        = local.bucket_name
#  acl           = "private"
#  force_destroy = true
#  acceleration_status = "Suspended"
#
#  attach_policy = true
#  policy        = data.aws_iam_policy_document.bucket_policy.json
#
#  attach_deny_insecure_transport_policy = true
#  attach_require_latest_tls_policy      = true
#
#  tags = {
#    Owner = "Anton"
#  }
#
#  versioning = {
#    enabled = true
#  }
#
#  website = {
#    index_document = "index.html"
#    error_document = "error.html"
#    routing_rules = jsonencode([{
#      Condition : {
#        KeyPrefixEquals : "docs/"
#      },
#      Redirect : {
#        ReplaceKeyPrefixWith : "documents/"
#      }
#    }])
#
#  }
#
#  logging = {
#    target_bucket = module.log_bucket.s3_bucket_id
#    target_prefix = "log/"
#  }
#
#  cors_rule = [
#    {
#      allowed_methods = ["PUT", "POST"]
#      allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
#      allowed_headers = ["*"]
#      expose_headers  = ["ETag"]
#      max_age_seconds = 3000
#      }, {
#      allowed_methods = ["PUT"]
#      allowed_origins = ["https://example.com"]
#      allowed_headers = ["*"]
#      expose_headers  = ["ETag"]
#      max_age_seconds = 3000
#    }
#  ]
#
#  lifecycle_rule = [
#    {
#      id      = "log"
#      enabled = true
#      prefix  = "log/"
#
#      tags = {
#        rule      = "log"
#        autoclean = "true"
#      }
#
#      transition = [
#        {
#          days          = 30
#          storage_class = "ONEZONE_IA"
#          }, {
#          days          = 60
#          storage_class = "GLACIER"
#        }
#      ]
#
#      expiration = {
#        days = 90
#      }
#
#      noncurrent_version_expiration = {
#        days = 30
#      }
#    },
#    {
#      id                                     = "log1"
#      enabled                                = true
#      prefix                                 = "log1/"
#      abort_incomplete_multipart_upload_days = 7
#
#      noncurrent_version_transition = [
#        {
#          days          = 30
#          storage_class = "STANDARD_IA"
#        },
#        {
#          days          = 60
#          storage_class = "ONEZONE_IA"
#        },
#        {
#          days          = 90
#          storage_class = "GLACIER"
#        },
#      ]
#
#      noncurrent_version_expiration = {
#        days = 300
#      }
#    },
#  ]
#
#  server_side_encryption_configuration = {
#    rule = {
#      apply_server_side_encryption_by_default = {
#        kms_master_key_id = aws_kms_key.objects.arn
#        sse_algorithm     = "aws:kms"
#      }
#    }
#  }
#
#  object_lock_configuration = {
#    object_lock_enabled = "Enabled"
#    rule = {
#      default_retention = {
#        mode = "GOVERNANCE"
#        days = 1
#      }
#    }
#  }
#
#  # S3 bucket-level Public Access Block configuration
#  block_public_acls       = true
#  block_public_policy     = true
#  ignore_public_acls      = true
#  restrict_public_buckets = true
#
#  # S3 Bucket Ownership Controls
#  control_object_ownership = true
#  object_ownership         = "BucketOwnerPreferred"
#}
