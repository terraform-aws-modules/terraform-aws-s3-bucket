provider "aws" {
  region = local.region
}

locals {
  region = "eu-west-1"
  name   = "ex-${basename(path.cwd)}"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}

data "aws_caller_identity" "current" {}

################################################################################
# S3 Bucket
################################################################################

module "simple_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-simple-"

  # For example only
  force_destroy = true

  tags = local.tags
}

module "simple_account_regional_bucket" {
  source = "../../"

  # An account-regional namespace bucket must carry the account id and region in its own
  # name, so it cannot use bucket_prefix
  bucket           = format("%s-simple-%s-%s-an", local.name, data.aws_caller_identity.current.account_id, local.region)
  bucket_namespace = "account-regional"

  # For example only
  force_destroy = true

  tags = local.tags
}

module "s3_bucket" {
  source = "../../"

  region = local.region

  bucket_prefix = "${local.name}-"

  # For example only
  force_destroy       = true
  acceleration_status = "Suspended"
  request_payer       = "BucketOwner"

  tags = local.tags

  # Note: Object Lock configuration can be enabled only on new buckets
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration
  object_lock_enabled = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 1
      }
    }
  }

  # S3 Metadata: an inventory table of object metadata, plus a journal of changes
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/metadata-tables-overview.html
  # Destroying this leaves the journal and inventory tables behind in the AWS managed table
  # bucket; only the configuration is removed. They are not Terraform managed, so nothing
  # here will clean them up, and re-creating a configuration for a bucket of the same name
  # fails until they are deleted by hand
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/metadata-tables-delete-configuration.html
  create_metadata_configuration                 = true
  metadata_inventory_table_configuration_state  = "ENABLED"
  metadata_journal_table_record_expiration      = "ENABLED"
  metadata_journal_table_record_expiration_days = 7
  metadata_encryption_configuration = {
    sse_algorithm = "aws:kms"
    kms_key_arn   = module.kms.key_arn
  }

  # Object Ownership is left at the module default of BucketOwnerEnforced, which disables ACLs
  # entirely. AWS recommends this for all but the few workloads that must grant access per
  # object; see examples/acl for those.
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html
  expected_bucket_owner                  = data.aws_caller_identity.current.account_id
  transition_default_minimum_object_size = "varies_by_storage_class"

  versioning = {
    status     = true
    mfa_delete = false
  }

  website = {
    # conflicts with "error_document"
    #        redirect_all_requests_to = {
    #          host_name = "https://modules.tf"
    #        }

    index_document = "index.html"
    error_document = "error.html"
    routing_rules = [{
      condition = {
        key_prefix_equals = "docs/"
      },
      redirect = {
        replace_key_prefix_with = "documents/"
      }
      }, {
      condition = {
        http_error_code_returned_equals = 404
        key_prefix_equals               = "archive/"
      },
      redirect = {
        host_name          = "archive.myhost.com"
        http_redirect_code = 301
        protocol           = "https"
        replace_key_with   = "not_found.html"
      }
    }]
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms.key_arn
        sse_algorithm     = "aws:kms"
      }
      blocked_encryption_types = ["SSE-C"]
    }
  }

  cors_rule = [
    {
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
      }, {
      allowed_methods = ["PUT"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  lifecycle_rule = [
    {
      id      = "log"
      enabled = true

      filter = {
        tags = {
          some    = "value"
          another = "value2"
        }
      }

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
          }, {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

      #        expiration = {
      #          days = 90
      #          expired_object_delete_marker = true
      #        }

      #        noncurrent_version_expiration = {
      #          newer_noncurrent_versions = 5
      #          days = 30
      #        }
    },
    {
      id                                     = "log1"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
    {
      id      = "log2"
      enabled = true

      filter = {
        prefix                   = "log1/"
        object_size_greater_than = 200000
        object_size_less_than    = 500000
        tags = {
          some    = "value"
          another = "value2"
        }
      }

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
  ]

  intelligent_tiering = {
    general = {
      status = "Enabled"
      filter = {
        prefix = "/"
        tags = {
          Environment = "dev"
        }
      }
      tiering = {
        ARCHIVE_ACCESS = {
          days = 180
        }
      }
    },
    documents = {
      status = false
      filter = {
        prefix = "documents/"
      }
      tiering = {
        ARCHIVE_ACCESS = {
          days = 125
        }
        DEEP_ARCHIVE_ACCESS = {
          days = 200
        }
      }
    }
  }

  metric_configuration = [
    {
      name = "documents"
      filter = {
        prefix = "documents/"
        tags = {
          priority = "high"
        }
      }
    },
    {
      name = "other"
      filter = {
        tags = {
          production = "true"
        }
      }
    },
    {
      name = "all"
    }
  ]

  # metadata configuration example
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/metadata-tables-overview.html
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/metadata-tables-configuring.html
  # only available in supported regions: https://docs.aws.amazon.com/AmazonS3/latest/userguide/metadata-tables-restrictions.html

  # create_metadata_configuration                 = true
  # metadata_inventory_table_configuration_state  = "ENABLED"
  # metadata_journal_table_record_expiration      = "ENABLED"
  # metadata_journal_table_record_expiration_days = 7
  # metadata_encryption_configuration = {
  #   sse_algorithm = "AES256"
  # }
}

module "disabled" {
  source = "../../"

  create_bucket = false

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  description             = "Key example for S3 bucket objects"
  deletion_window_in_days = 7

  # S3 Metadata builds its inventory and journal on S3 Tables, and those tables are encrypted
  # by a service principal rather than by the caller
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/metadata-tables-permissions.html
  key_statements = [
    {
      sid       = "S3MetadataTables"
      actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
      resources = ["*"]

      principals = [
        {
          type        = "Service"
          identifiers = ["maintenance.s3tables.amazonaws.com", "metadata.s3.amazonaws.com"]
        }
      ]
    }
  ]

  tags = local.tags
}
