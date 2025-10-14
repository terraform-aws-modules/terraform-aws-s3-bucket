locals {
  bucket_name         = "origin-s3-bucket-${random_pet.this.id}"
  replica_bucket_name = "replica-s3-bucket-${random_pet.this.id}"

  origin_region  = "eu-west-1"
  replica_region = "eu-central-1"
}

provider "aws" {
  region = local.origin_region
  alias  = "source"
}

provider "aws" {
  region = local.replica_region
  alias  = "replica"
}

resource "random_pet" "this" {
  length = 2
}

module "s3_bucket" {
  source = "../../"

  providers = {
    aws = aws.source
  }

  bucket = local.bucket_name

  force_destroy = true

  # Versioning
  versioning = {
    enabled = true
  }

  # Replication
  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id       = "built-in-rule-repl1"
        priority = 10
        status   = true

        delete_marker_replication = true

        destination = {
          bucket             = "arn:aws:s3:::${local.replica_bucket_name}"
          replica_kms_key_id = aws_kms_key.replica.arn

          metrics = {
            status  = "Enabled"
            minutes = 15
          }

          replication_time = {
            status  = "Enabled"
            minutes = 15
          }
        }

        source_selection_criteria = {
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }
      },

      {
        id                        = "custom-additional-rule",
        priority                  = 15,
        delete_marker_replication = true

        destination = {
          bucket             = "arn:aws:s3:::${local.replica_bucket_name}"
          replica_kms_key_id = aws_kms_key.replica.arn
          storage_class      = "STANDARD_IA"
        }

        filter = {
          prefix = ""
        }

        source_selection_criteria = {
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

      },

      {
        id       = "built-in-rule-repl2"
        priority = 20
        status   = true

        delete_marker_replication = true

        destination = {
          bucket             = "arn:aws:s3:::${local.replica_bucket_name}"
          replica_kms_key_id = aws_kms_key.replica.arn

          metrics = {
            status  = "Enabled"
            minutes = 15
          }

          replication_time = {
            status  = "Enabled"
            minutes = 15
          }
        }

        source_selection_criteria = {
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }
      }
    ]
  }

  # Lifecycle
  lifecycle_rule = [
    {
      id     = "abort-incomplete-multipart-upload"
      status = "Enabled"

      abort_incomplete_multipart_upload = {
        days_after_initiation = 35
      }

      filter = {
      }

      noncurrent_version_expiration = {
        noncurrent_days = 35
      }
    },

    {
      id     = "log1"
      status = "Enabled"

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }

      filter = {
      }

      noncurrent_version_expiration = {
        noncurrent_days = 300
      }

      noncurrent_version_transition = {
        noncurrent_days = 30
        storage_class   = "STANDARD_IA"
      }
      noncurrent_version_transition = {
        noncurrent_days = 60
        storage_class   = "ONEZONE_IA"
      }
      noncurrent_version_transition = {
        noncurrent_days = 90
        storage_class   = "GLACIER"
      }
    }
  ]

  depends_on = [module.bucket_replica]
}

resource "aws_kms_key" "replica" {
  provider = aws.replica

  description             = "S3 bucket replication KMS key"
  deletion_window_in_days = 7
}

module "bucket_replica" {
  source = "../../"

  providers = {
    aws = aws.replica
  }

  versioning = {
    enabled = true
  }

  bucket = local.replica_bucket_name

  force_destroy = true
}
