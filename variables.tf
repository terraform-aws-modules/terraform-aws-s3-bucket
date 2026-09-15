# TODO: rename to `create`, the fleet-wide name for the module-wide toggle. Breaking:
# renaming a variable forces every caller to change and has no `moved` equivalent.
variable "create_bucket" {
  description = "Controls if S3 bucket should be created"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}

################################################################################
# Bucket
################################################################################

variable "bucket" {
  description = "The name of the bucket. If omitted, Terraform will assign a random, unique name"
  type        = string
  default     = null
}

variable "bucket_prefix" {
  description = "Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket"
  type        = string
  default     = null
}

variable "bucket_namespace" {
  description = "Namespace for the bucket. Determines bucket naming scope. Valid values: `account-regional`, `global`. Defaults to `global` (AWS)"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable"
  type        = bool
  default     = false
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner"
  type        = string
  default     = null
}

variable "owner" {
  description = "Bucket owner's display name and ID. Conflicts with `acl`"
  type        = map(string)
  default     = {}
}

# Directory Bucket
variable "is_directory_bucket" {
  description = "If the s3 bucket created is a directory bucket"
  type        = bool
  default     = false
}

variable "type" {
  description = "Bucket type. Valid values: `Directory`"
  type        = string
  default     = "Directory"
}

variable "data_redundancy" {
  description = "Data redundancy. Valid values: `SingleAvailabilityZone`"
  type        = string
  default     = null
}

variable "availability_zone_id" {
  description = "Availability Zone ID or Local Zone ID"
  type        = string
  default     = null
}

variable "location_type" {
  description = "Location type. Valid values: `AvailabilityZone` or `LocalZone`"
  type        = string
  default     = null
}

################################################################################
# Logging
################################################################################

variable "logging" {
  description = "Access log delivery configuration for the bucket"
  type = object({
    target_bucket = string
    target_prefix = optional(string)
    target_object_key_format = optional(object({
      partitioned_prefix = optional(object({
        partition_date_source = optional(string)
      }))
      simple_prefix = optional(object({}))
    }))
  })
  default = null
}

################################################################################
# ACL
################################################################################

# TODO: consider removing. AWS recommends disabling ACLs entirely, and Object Ownership
# defaults to `BucketOwnerEnforced` where `acl` and `grant` are rejected outright. Retained
# because callers on legacy CloudFront standard logging still require them.
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html
variable "acl" {
  description = "The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "grant" {
  description = "ACL policy grants for the bucket. Conflicts with `acl`"
  type = list(object({
    id         = optional(string)
    type       = string
    permission = string
    uri        = optional(string)
    email      = optional(string)
  }))
  default = []
}

################################################################################
# Website
################################################################################

variable "website" {
  description = "Static website hosting or redirect configuration for the bucket"
  type = object({
    index_document = optional(string)
    error_document = optional(string)
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string)
    }))
    routing_rules = optional(list(object({
      condition = optional(object({
        http_error_code_returned_equals = optional(string)
        key_prefix_equals               = optional(string)
      }))
      redirect = optional(object({
        host_name               = optional(string)
        http_redirect_code      = optional(string)
        protocol                = optional(string)
        replace_key_prefix_with = optional(string)
        replace_key_with        = optional(string)
      }))
    })))
  })
  default = {}
}

################################################################################
# Versioning
################################################################################

# TODO: type this as an object. `map(string)` coerces `enabled = true` to `"true"`, which
# main.tf then has to convert back through a four-deep `try()` chain. Breaking: the accepted
# input shape changes.
variable "versioning" {
  description = "Versioning configuration for the bucket"
  type        = map(string)
  default     = {}
}

################################################################################
# Server-Side Encryption
################################################################################

variable "server_side_encryption_configuration" {
  description = "Server-side encryption configuration for the bucket"
  type = object({
    # AWS permits a single rule per bucket, and every example passes one object
    rule = optional(object({
      bucket_key_enabled       = optional(bool)
      blocked_encryption_types = optional(list(string))
      apply_server_side_encryption_by_default = optional(object({
        sse_algorithm     = string
        kms_master_key_id = optional(string)
      }))
    }))
  })
  default = {}
}

variable "allowed_kms_key_arn" {
  description = "The ARN of KMS key which should be allowed in PutObject"
  type        = string
  default     = null
}

################################################################################
# Acceleration
################################################################################

variable "acceleration_status" {
  description = "Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended"
  type        = string
  default     = null
}

################################################################################
# Request Payment
################################################################################

variable "request_payer" {
  description = "Specifies who should bear the cost of Amazon S3 data transfer. Can be either `BucketOwner` or `Requester`. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information"
  type        = string
  default     = null
}

################################################################################
# CORS Rule(s)
################################################################################

variable "cors_rule" {
  description = "Rules for Cross-Origin Resource Sharing on the bucket"
  type = list(object({
    id              = optional(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string))
    expose_headers  = optional(list(string))
    max_age_seconds = optional(number)
  }))
  default = []
}

################################################################################
# Lifecycle Rule(s)
################################################################################

variable "lifecycle_rule" {
  description = "Object lifecycle management rules for the bucket"
  type = list(object({
    id      = optional(string)
    prefix  = optional(string)
    enabled = optional(bool)
    status  = optional(string)

    abort_incomplete_multipart_upload_days = optional(number)

    expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))
    filter = optional(object({
      object_size_greater_than = optional(number)
      object_size_less_than    = optional(number)
      prefix                   = optional(string)
      tags                     = optional(map(string))
      tag                      = optional(map(string))
    }))
    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number)
      days                      = optional(number)
      noncurrent_days           = optional(number)
    }))
    noncurrent_version_transition = optional(list(object({
      newer_noncurrent_versions = optional(number)
      days                      = optional(number)
      noncurrent_days           = optional(number)
      storage_class             = string
    })), [])
    transition = optional(list(object({
      date          = optional(string)
      days          = optional(number)
      storage_class = string
    })), [])
  }))
  default = []
}

variable "transition_default_minimum_object_size" {
  description = "The default minimum object size behavior applied to the lifecycle configuration. Valid values: `all_storage_classes_128K` (default) or `varies_by_storage_class`"
  type        = string
  default     = null
}

################################################################################
# Object Lock
################################################################################

variable "object_lock_enabled" {
  description = "Whether S3 bucket should have an Object Lock configuration enabled"
  type        = bool
  default     = false
}

variable "object_lock_configuration" {
  description = "Object lock configuration for the bucket"
  type = object({
    token = optional(string)
    rule = optional(object({
      default_retention = object({
        mode  = string
        days  = optional(number)
        years = optional(number)
      })
    }))
  })
  default = {}
}

################################################################################
# Replication
################################################################################

variable "replication_configuration" {
  description = "Cross-region replication configuration for the bucket"
  type = object({
    role = optional(string)

    # `rules` is the original name, `rule` was added to match the provider block. Set either
    rule = optional(list(object({
      id       = optional(string)
      priority = optional(number)
      status   = optional(string)
      prefix   = optional(string)

      # Both spellings are accepted; the newer one matches the provider block name
      delete_marker_replication          = optional(string)
      delete_marker_replication_status   = optional(string)
      existing_object_replication        = optional(string)
      existing_object_replication_status = optional(string)

      filter = optional(object({
        prefix = optional(string)
        tags   = optional(map(string))
        tag    = optional(map(string))
      }))
      source_selection_criteria = optional(object({
        replica_modifications = optional(object({
          enabled = optional(string)
          status  = optional(string)
        }))
        sse_kms_encrypted_objects = optional(object({
          enabled = optional(string)
          status  = optional(string)
        }))
      }))
      destination = object({
        bucket        = string
        storage_class = optional(string)
        account       = optional(string)
        account_id    = optional(string)

        replica_kms_key_id = optional(string)
        encryption_configuration = optional(object({
          replica_kms_key_id = optional(string)
        }))
        access_control_translation = optional(object({
          owner = string
        }))
        replication_time = optional(object({
          status  = optional(string)
          minutes = optional(number)
        }))
        metrics = optional(object({
          status  = optional(string)
          minutes = optional(number)
        }))
      })
    })))
    rules = optional(list(object({
      id       = optional(string)
      priority = optional(number)
      status   = optional(string)
      prefix   = optional(string)

      # Both spellings are accepted; the newer one matches the provider block name
      delete_marker_replication          = optional(string)
      delete_marker_replication_status   = optional(string)
      existing_object_replication        = optional(string)
      existing_object_replication_status = optional(string)

      filter = optional(object({
        prefix = optional(string)
        tags   = optional(map(string))
        tag    = optional(map(string))
      }))
      source_selection_criteria = optional(object({
        replica_modifications = optional(object({
          enabled = optional(string)
          status  = optional(string)
        }))
        sse_kms_encrypted_objects = optional(object({
          enabled = optional(string)
          status  = optional(string)
        }))
      }))
      destination = object({
        bucket        = string
        storage_class = optional(string)
        account       = optional(string)
        account_id    = optional(string)

        replica_kms_key_id = optional(string)
        encryption_configuration = optional(object({
          replica_kms_key_id = optional(string)
        }))
        access_control_translation = optional(object({
          owner = string
        }))
        replication_time = optional(object({
          status  = optional(string)
          minutes = optional(number)
        }))
        metrics = optional(object({
          status  = optional(string)
          minutes = optional(number)
        }))
      })
    })))
  })
  default = {}
}

################################################################################
# Bucket Policy
################################################################################

variable "attach_policy" {
  description = "Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy)"
  type        = bool
  default     = false
}

variable "policy" {
  description = "A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide"
  type        = string
  default     = null
}

# TODO: the name and description both describe a bucket policy, but this gates the
# `aws_s3_bucket_public_access_block` resource. Renaming it to `create_public_access_block`
# is an API change, so it waits for the next major
variable "attach_public_policy" {
  description = "Controls if the S3 Bucket Public Access Block is created (set to `false` to allow upstream to apply defaults to the bucket)"
  type        = bool
  default     = true
}

variable "attach_elb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ELB log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_lb_log_delivery_policy" {
  description = "Controls if S3 bucket should have ALB/NLB log delivery policy attached"
  type        = bool
  default     = false
}

variable "lb_log_delivery_policy_source_organizations" {
  description = "List of AWS Organization IDs should be allowed to deliver ALB/NLB logs to this bucket"
  type        = list(string)
  default     = []
}

variable "attach_access_log_delivery_policy" {
  description = "Controls if S3 bucket should have S3 access log delivery policy attached"
  type        = bool
  default     = false
}

variable "access_log_delivery_policy_source_buckets" {
  description = "List of S3 bucket ARNs which should be allowed to deliver access logs to this bucket"
  type        = list(string)
  default     = []
}

variable "access_log_delivery_policy_source_accounts" {
  description = "List of AWS Account IDs should be allowed to deliver access logs to this bucket"
  type        = list(string)
  default     = []
}

variable "access_log_delivery_policy_source_organizations" {
  description = "List of AWS Organization IDs should be allowed to deliver access logs to this bucket"
  type        = list(string)
  default     = []
}

variable "attach_waf_log_delivery_policy" {
  description = "Controls if S3 bucket should have WAF log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_cloudtrail_log_delivery_policy" {
  description = "Controls if S3 bucket should have CloudTrail log delivery policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_insecure_transport_policy" {
  description = "Controls if S3 bucket should have deny non-SSL transport policy attached"
  type        = bool
  default     = false
}

variable "attach_require_latest_tls_policy" {
  description = "Controls if S3 bucket should require the latest version of TLS"
  type        = bool
  default     = false
}

variable "attach_deny_incorrect_encryption_headers" {
  description = "Controls if S3 bucket should deny incorrect encryption headers policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_incorrect_kms_key_sse" {
  description = "Controls if S3 bucket policy should deny usage of incorrect KMS key SSE"
  type        = bool
  default     = false
}

variable "attach_deny_unencrypted_object_uploads" {
  description = "Controls if S3 bucket should deny unencrypted object uploads policy attached"
  type        = bool
  default     = false
}

variable "attach_deny_ssec_encrypted_object_uploads" {
  description = "Controls if S3 bucket should deny SSEC encrypted object uploads"
  type        = bool
  default     = false
}

variable "attach_inventory_destination_policy" {
  description = "Controls if S3 bucket should have bucket inventory destination policy attached"
  type        = bool
  default     = false
}

variable "attach_analytics_destination_policy" {
  description = "Controls if S3 bucket should have bucket analytics destination policy attached"
  type        = bool
  default     = false
}

################################################################################
# Public Access Block
################################################################################

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket"
  type        = bool
  default     = true
}

variable "skip_destroy_public_access_block" {
  description = "Whether to skip destroying the S3 Bucket Public Access Block configuration when destroying the bucket. Only used if `public_access_block` is set to true"
  type        = bool
  default     = true
}

################################################################################
# Ownership Controls
################################################################################

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket"
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: `BucketOwnerEnforced`, `BucketOwnerPreferred` or `ObjectWriter`. `BucketOwnerEnforced`: ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. `BucketOwnerPreferred`: Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the `bucket-owner-full-control` canned ACL. `ObjectWriter`: The uploading account will own the object if the object is uploaded with the `bucket-owner-full-control` canned ACL"
  type        = string
  default     = "BucketOwnerEnforced"
}

################################################################################
# Intelligent Tiering
################################################################################

variable "intelligent_tiering" {
  description = "Intelligent tiering configurations for the bucket, keyed by configuration name"
  type = map(object({
    status = optional(string)
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    tiering = map(object({
      days = number
    }))
  }))
  default = {}
}

################################################################################
# Metric(s)
################################################################################

variable "metric_configuration" {
  description = "Metric configurations for the bucket"
  # TODO: change to `map(object(...))` keyed by the caller. `aws_s3_bucket_metric` requires
  # `[bucket, name]`, so many exist per bucket and house style keys them by name. Breaking:
  # `for_each` keys a list by position, so re-keying re-addresses and recreates every existing
  # configuration. Measured: 12 public callers pass a list, none passes a map.
  # conformance.py's FOREACH_LIST flags this deliberately and is the marker for it.
  type = list(object({
    name = string
    filter = optional(object({
      prefix       = optional(string)
      tags         = optional(map(string))
      access_point = optional(string)
    }))
  }))
  default = []
}

################################################################################
# Inventory
################################################################################

variable "inventory_configuration" {
  description = "Inventory configurations for the bucket, keyed by configuration name"
  type = map(object({
    bucket                   = optional(string)
    included_object_versions = string
    enabled                  = optional(bool, true)
    optional_fields          = optional(list(string))
    frequency                = string
    destination = object({
      bucket_arn = optional(string)
      format     = optional(string)
      account_id = optional(string)
      prefix     = optional(string)
      encryption = optional(object({
        encryption_type = string
        kms_key_id      = optional(string)
      }))
    })
    filter = optional(object({
      prefix = optional(string)
    }))
  }))
  default = {}
}

variable "inventory_source_account_id" {
  description = "The inventory source account id"
  type        = string
  default     = null
}

variable "inventory_source_bucket_arn" {
  description = "The inventory source bucket ARN"
  type        = string
  default     = null
}

variable "inventory_self_source_destination" {
  description = "Whether or not the inventory source bucket is also the destination bucket"
  type        = bool
  default     = false
}

################################################################################
# Analytics
################################################################################

variable "analytics_configuration" {
  description = "Analytics configurations for the bucket, keyed by configuration name"
  type = map(object({
    filter = optional(object({
      prefix = optional(string)
      tags   = optional(map(string))
    }))
    storage_class_analysis = optional(object({
      output_schema_version  = optional(string)
      destination_bucket_arn = optional(string)
      destination_account_id = optional(string)
      export_format          = optional(string)
      export_prefix          = optional(string)
    }))
  }))
  default = {}
}

variable "analytics_source_account_id" {
  description = "The analytics source account id"
  type        = string
  default     = null
}

variable "analytics_source_bucket_arn" {
  description = "The analytics source bucket ARN"
  type        = string
  default     = null
}

variable "analytics_self_source_destination" {
  description = "Whether or not the analytics source bucket is also the destination bucket"
  type        = bool
  default     = false
}

################################################################################
# Metadata
################################################################################

variable "create_metadata_configuration" {
  description = "Whether to create metadata configuration resource"
  type        = bool
  default     = false
}

variable "metadata_inventory_table_configuration_state" {
  description = "Configuration state of the inventory table, indicating whether the inventory table is enabled or disabled. Valid values: `ENABLED`, `DISABLED`"
  type        = string
  default     = null
}

variable "metadata_encryption_configuration" {
  description = "Encryption configuration for the metadata inventory table"
  type = object({
    kms_key_arn   = optional(string)
    sse_algorithm = string
  })
  default = null
}

variable "metadata_journal_table_record_expiration_days" {
  description = "Number of days to retain journal table records"
  type        = number
  default     = null
}

variable "metadata_journal_table_record_expiration" {
  description = "Whether journal table record expiration is enabled or disabled. Valid values: `ENABLED`, `DISABLED`"
  type        = string
  default     = null
}

variable "putin_khuylo" {
  description = "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo!"
  type        = bool
  default     = true
}
