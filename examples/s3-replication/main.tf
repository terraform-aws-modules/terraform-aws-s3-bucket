provider "aws" {
  region = local.origin_region
}

provider "aws" {
  region = local.replica_region

  alias = "replica"
}

locals {
  name           = "ex-${basename(path.cwd)}"
  origin_region  = "eu-west-1"
  replica_region = "eu-central-1"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}

data "aws_caller_identity" "current" {}

################################################################################
# Cross-Region Replication
################################################################################

module "replica_bucket" {
  source = "../../"

  providers = {
    aws = aws.replica
  }

  bucket_prefix = "${local.name}-replica-"

  versioning = {
    enabled = true
  }

  tags = local.tags
}

module "s3_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-origin-"

  versioning = {
    enabled = true
  }

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id       = "something-with-kms-and-filter"
        status   = true
        priority = 10

        delete_marker_replication = false

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        filter = {
          prefix = "one"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket        = module.replica_bucket.s3_bucket_arn
          storage_class = "STANDARD"

          replica_kms_key_id = module.kms_replica.key_arn
          account_id         = data.aws_caller_identity.current.account_id

          access_control_translation = {
            owner = "Destination"
          }

          replication_time = {
            status  = "Enabled"
            minutes = 15
          }

          metrics = {
            status  = "Enabled"
            minutes = 15
          }
        }
      },
      {
        id       = "something-with-filter"
        priority = 20

        delete_marker_replication = false

        filter = {
          prefix = "two"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket        = module.replica_bucket.s3_bucket_arn
          storage_class = "STANDARD"
        }
      },
      {
        id       = "everything-with-filter"
        status   = "Enabled"
        priority = 30

        delete_marker_replication = true

        filter = {
          prefix = ""
        }

        destination = {
          bucket        = module.replica_bucket.s3_bucket_arn
          storage_class = "STANDARD"
        }
      },
      {
        id     = "everything-without-filters"
        status = "Enabled"

        delete_marker_replication = true

        destination = {
          bucket        = module.replica_bucket.s3_bucket_arn
          storage_class = "STANDARD"
        }
      },
    ]
  }

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "kms_replica" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.replica
  }

  description             = "S3 bucket replication KMS key"
  deletion_window_in_days = 7

  tags = local.tags
}
