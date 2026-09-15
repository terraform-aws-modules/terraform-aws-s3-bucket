data "aws_region" "current" {
  region = var.region
}

data "aws_canonical_user_id" "this" {
  count = local.create_bucket && local.create_bucket_acl && try(var.owner["id"], null) == null ? 1 : 0
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  dns_suffix = data.aws_partition.current.dns_suffix
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.region
}

locals {
  create_bucket = var.create_bucket && var.putin_khuylo

  create_bucket_acl = (var.acl != null && var.acl != "null") || length(local.grants) > 0

  attach_policy = var.attach_require_latest_tls_policy || var.attach_access_log_delivery_policy || var.attach_elb_log_delivery_policy || var.attach_lb_log_delivery_policy || var.attach_cloudtrail_log_delivery_policy || var.attach_deny_insecure_transport_policy || var.attach_inventory_destination_policy || var.attach_analytics_destination_policy || var.attach_deny_incorrect_encryption_headers || var.attach_deny_incorrect_kms_key_sse || var.attach_deny_unencrypted_object_uploads || var.attach_deny_ssec_encrypted_object_uploads || var.attach_policy || var.attach_waf_log_delivery_policy

  # Placeholders in the policy document to be replaced with the actual values
  policy_placeholders = {
    "_S3_BUCKET_ID_"   = try(var.is_directory_bucket ? aws_s3_directory_bucket.this[0].bucket : aws_s3_bucket.this[0].id, null),
    "_S3_BUCKET_ARN_"  = try(var.is_directory_bucket ? aws_s3_directory_bucket.this[0].arn : aws_s3_bucket.this[0].arn, null),
    "_AWS_ACCOUNT_ID_" = local.account_id
  }

  policy = local.create_bucket && local.attach_policy ? replace(
    replace(
      replace(
        data.aws_iam_policy_document.combined[0].json,
        "_S3_BUCKET_ID_", local.policy_placeholders["_S3_BUCKET_ID_"]
      ),
      "_S3_BUCKET_ARN_", local.policy_placeholders["_S3_BUCKET_ARN_"]
    ),
    "_AWS_ACCOUNT_ID_", local.policy_placeholders["_AWS_ACCOUNT_ID_"]
  ) : ""

  # A website configuration is only created when the caller sets something in it; an object
  # with every attribute null is equivalent to not configuring a website at all.
  has_website = anytrue([
    try(var.website.index_document, null) != null,
    try(var.website.error_document, null) != null,
    try(var.website.redirect_all_requests_to, null) != null,
    try(var.website.routing_rules, null) != null,
  ])

  # Presence is tested on the attributes themselves, never on their contents: a rule's
  # destination is normally a computed bucket ARN, and wrapping this in try()/coalesce()
  # makes the whole expression unknown, which breaks the `count` below at plan time.
  has_replication   = var.replication_configuration.rule != null || var.replication_configuration.rules != null
  replication_rules = var.replication_configuration.rule != null ? var.replication_configuration.rule : (var.replication_configuration.rules != null ? var.replication_configuration.rules : [])

  grants              = var.grant
  cors_rules          = var.cors_rule
  intelligent_tiering = var.intelligent_tiering

  # Still `any`, so still reachable as a JSON string from Terragrunt. The hatch goes when the
  # variables are typed; see their declarations for why they are not typed yet.
}

################################################################################
# Bucket
################################################################################

resource "aws_s3_bucket" "this" {
  count = local.create_bucket && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket           = var.bucket
  bucket_prefix    = var.bucket_prefix
  bucket_namespace = var.bucket_namespace

  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_directory_bucket" "this" {
  count = local.create_bucket && var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket          = "${var.bucket}--${var.availability_zone_id}--x-s3"
  data_redundancy = var.data_redundancy
  force_destroy   = var.force_destroy
  type            = var.type

  location {
    name = var.availability_zone_id
    type = var.location_type
  }

  tags = var.tags
}

################################################################################
# Logging
################################################################################

resource "aws_s3_bucket_logging" "this" {
  count = local.create_bucket && var.logging != null && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket = aws_s3_bucket.this[0].id

  target_bucket = var.logging.target_bucket
  target_prefix = var.logging.target_prefix

  dynamic "target_object_key_format" {
    for_each = var.logging.target_object_key_format != null ? [var.logging.target_object_key_format] : []

    content {
      dynamic "partitioned_prefix" {
        for_each = target_object_key_format.value.partitioned_prefix != null ? [target_object_key_format.value.partitioned_prefix] : []

        content {
          partition_date_source = partitioned_prefix.value.partition_date_source
        }
      }

      dynamic "simple_prefix" {
        for_each = target_object_key_format.value.partitioned_prefix == null || target_object_key_format.value.simple_prefix != null ? [true] : []

        content {}
      }
    }
  }
}

################################################################################
# ACL
################################################################################

resource "aws_s3_bucket_acl" "this" {
  count = local.create_bucket && local.create_bucket_acl && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner

  # hack when `null` value can't be used (eg, from terragrunt, https://github.com/gruntwork-io/terragrunt/pull/1367)
  acl = var.acl == "null" ? null : var.acl

  dynamic "access_control_policy" {
    for_each = length(local.grants) > 0 ? [true] : []

    content {
      dynamic "grant" {
        for_each = local.grants

        content {
          permission = grant.value.permission

          grantee {
            type          = grant.value.type
            id            = grant.value.id
            uri           = grant.value.uri
            email_address = grant.value.email
          }
        }
      }

      owner {
        id           = try(var.owner["id"], data.aws_canonical_user_id.this[0].id)
        display_name = try(var.owner["display_name"], null)
      }
    }
  }

  # This `depends_on` is to prevent "AccessControlListNotSupported: The bucket does not allow ACLs."
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

################################################################################
# Website
################################################################################

resource "aws_s3_bucket_website_configuration" "this" {
  count = local.create_bucket && local.has_website && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "index_document" {
    for_each = var.website.index_document != null ? [var.website.index_document] : []

    content {
      suffix = index_document.value
    }
  }

  dynamic "error_document" {
    for_each = var.website.error_document != null ? [var.website.error_document] : []

    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website.redirect_all_requests_to != null ? [var.website.redirect_all_requests_to] : []

    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }

  dynamic "routing_rule" {
    for_each = coalesce(var.website.routing_rules, [])

    content {
      dynamic "condition" {
        for_each = routing_rule.value.condition != null ? [routing_rule.value.condition] : []

        content {
          http_error_code_returned_equals = condition.value.http_error_code_returned_equals
          key_prefix_equals               = condition.value.key_prefix_equals
        }
      }

      redirect {
        host_name               = try(routing_rule.value.redirect.host_name, null)
        http_redirect_code      = try(routing_rule.value.redirect.http_redirect_code, null)
        protocol                = try(routing_rule.value.redirect.protocol, null)
        replace_key_prefix_with = try(routing_rule.value.redirect.replace_key_prefix_with, null)
        replace_key_with        = try(routing_rule.value.redirect.replace_key_with, null)
      }
    }
  }
}

################################################################################
# Versioning
################################################################################

resource "aws_s3_bucket_versioning" "this" {
  count = local.create_bucket && length(keys(var.versioning)) > 0 && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner
  mfa                   = try(var.versioning["mfa"], null)

  versioning_configuration {
    # Valid values: "Enabled" or "Suspended"
    status = try(var.versioning["enabled"] ? "Enabled" : "Suspended", tobool(var.versioning["status"]) ? "Enabled" : "Suspended", title(lower(var.versioning["status"])), "Enabled")

    # Valid values: "Enabled" or "Disabled"
    mfa_delete = try(tobool(var.versioning["mfa_delete"]) ? "Enabled" : "Disabled", title(lower(var.versioning["mfa_delete"])), null)
  }
}

################################################################################
# Server-Side Encryption
################################################################################

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = local.create_bucket && var.server_side_encryption_configuration.rule != null ? 1 : 0

  region = var.region

  bucket                = var.is_directory_bucket ? aws_s3_directory_bucket.this[0].bucket : aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "rule" {
    for_each = var.server_side_encryption_configuration.rule != null ? [var.server_side_encryption_configuration.rule] : []

    content {
      bucket_key_enabled = rule.value.bucket_key_enabled

      dynamic "apply_server_side_encryption_by_default" {
        for_each = rule.value.apply_server_side_encryption_by_default != null ? [rule.value.apply_server_side_encryption_by_default] : []

        content {
          sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
          kms_master_key_id = apply_server_side_encryption_by_default.value.kms_master_key_id
        }
      }
      blocked_encryption_types = rule.value.blocked_encryption_types
    }
  }
}

################################################################################
# Acceleration
################################################################################

resource "aws_s3_bucket_accelerate_configuration" "this" {
  count = local.create_bucket && var.acceleration_status != null && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner

  # Valid values: "Enabled" or "Suspended"
  status = title(lower(var.acceleration_status))
}

################################################################################
# Request Payment
################################################################################

resource "aws_s3_bucket_request_payment_configuration" "this" {
  count = local.create_bucket && var.request_payer != null && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner

  # Valid values: "BucketOwner" or "Requester"
  payer = lower(var.request_payer) == "requester" ? "Requester" : "BucketOwner"
}

################################################################################
# CORS Rule(s)
################################################################################

resource "aws_s3_bucket_cors_configuration" "this" {
  count = local.create_bucket && length(local.cors_rules) > 0 && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "cors_rule" {
    for_each = local.cors_rules

    content {
      id              = cors_rule.value.id
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = cors_rule.value.allowed_headers
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

################################################################################
# Lifecycle Rule(s)
################################################################################

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = local.create_bucket && length(var.lifecycle_rule) > 0 ? 1 : 0

  region = var.region

  bucket                                 = var.is_directory_bucket ? aws_s3_directory_bucket.this[0].bucket : aws_s3_bucket.this[0].id
  expected_bucket_owner                  = var.expected_bucket_owner
  transition_default_minimum_object_size = var.transition_default_minimum_object_size

  dynamic "rule" {
    for_each = var.lifecycle_rule

    content {
      id     = rule.value.id
      status = rule.value.enabled != null ? (rule.value.enabled ? "Enabled" : "Disabled") : try(tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days != null ? [rule.value.abort_incomplete_multipart_upload_days] : []

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }


      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []

        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = rule.value.transition

        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []

        content {
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
          noncurrent_days           = noncurrent_version_expiration.value.days != null ? noncurrent_version_expiration.value.days : noncurrent_version_expiration.value.noncurrent_days
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition

        content {
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
          noncurrent_days           = noncurrent_version_transition.value.days != null ? noncurrent_version_transition.value.days : noncurrent_version_transition.value.noncurrent_days
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = rule.value.filter == null || max(
          length([for k, a in {
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
            prefix                   = rule.value.filter.prefix
            tags                     = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) == 0 ? [true] : []

        content {
          #          prefix = ""
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = rule.value.filter != null && max(
          length([for k, a in {
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
            prefix                   = rule.value.filter.prefix
            tags                     = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) == 1 ? [rule.value.filter] : []

        content {
          object_size_greater_than = filter.value.object_size_greater_than
          object_size_less_than    = filter.value.object_size_less_than
          prefix                   = filter.value.prefix

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : filter.value.tag != null ? filter.value.tag : {}

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = rule.value.filter != null && max(
          length([for k, a in {
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
            prefix                   = rule.value.filter.prefix
            tags                     = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) > 1 ? [rule.value.filter] : []

        content {
          and {
            object_size_greater_than = filter.value.object_size_greater_than
            object_size_less_than    = filter.value.object_size_less_than
            prefix                   = filter.value.prefix
            tags                     = filter.value.tags != null ? filter.value.tags : filter.value.tag
          }
        }
      }
    }
  }

  depends_on = [
    # Must have bucket versioning enabled first
    aws_s3_bucket_versioning.this,
    # Must wait for replication configuration to propagate
    aws_s3_bucket_replication_configuration.this
  ]
}

################################################################################
# Object Lock
################################################################################

resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = local.create_bucket && var.object_lock_enabled && try(var.object_lock_configuration.rule.default_retention, null) != null ? 1 : 0

  region = var.region

  bucket                = aws_s3_bucket.this[0].id
  expected_bucket_owner = var.expected_bucket_owner
  token                 = var.object_lock_configuration.token

  rule {
    default_retention {
      mode  = var.object_lock_configuration.rule.default_retention.mode
      days  = var.object_lock_configuration.rule.default_retention.days
      years = var.object_lock_configuration.rule.default_retention.years
    }
  }
}

################################################################################
# Replication
################################################################################

resource "aws_s3_bucket_replication_configuration" "this" {
  count = local.create_bucket && local.has_replication && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket = aws_s3_bucket.this[0].id
  role   = var.replication_configuration.role

  dynamic "rule" {
    for_each = local.replication_rules

    content {
      id       = rule.value.id
      priority = rule.value.priority
      status   = rule.value.status == null ? "Enabled" : try(tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      dynamic "delete_marker_replication" {
        for_each = compact([rule.value.delete_marker_replication_status != null ? rule.value.delete_marker_replication_status : rule.value.delete_marker_replication])

        content {
          # Valid values: "Enabled" or "Disabled"
          status = try(tobool(delete_marker_replication.value) ? "Enabled" : "Disabled", title(lower(delete_marker_replication.value)))
        }
      }

      # Amazon S3 does not support this argument according to:
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration
      # More infor about what does Amazon S3 replicate?
      # https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-what-is-isnot-replicated.html
      dynamic "existing_object_replication" {
        for_each = compact([rule.value.existing_object_replication_status != null ? rule.value.existing_object_replication_status : rule.value.existing_object_replication])

        content {
          # Valid values: "Enabled" or "Disabled"
          status = try(tobool(existing_object_replication.value) ? "Enabled" : "Disabled", title(lower(existing_object_replication.value)))
        }
      }

      dynamic "destination" {
        for_each = [rule.value.destination]

        content {
          bucket        = destination.value.bucket
          storage_class = destination.value.storage_class
          account       = destination.value.account_id != null ? destination.value.account_id : destination.value.account

          dynamic "access_control_translation" {
            for_each = destination.value.access_control_translation != null ? [destination.value.access_control_translation] : []

            content {
              owner = title(lower(access_control_translation.value.owner))
            }
          }

          dynamic "encryption_configuration" {
            for_each = compact([try(destination.value.encryption_configuration.replica_kms_key_id, null) != null ? destination.value.encryption_configuration.replica_kms_key_id : destination.value.replica_kms_key_id])

            content {
              replica_kms_key_id = encryption_configuration.value
            }
          }

          dynamic "replication_time" {
            for_each = destination.value.replication_time != null ? [destination.value.replication_time] : []

            content {
              # Valid values: "Enabled" or "Disabled"
              status = replication_time.value.status == null ? "Disabled" : try(tobool(replication_time.value.status) ? "Enabled" : "Disabled", title(lower(replication_time.value.status)))

              dynamic "time" {
                for_each = replication_time.value.minutes != null ? [replication_time.value.minutes] : []

                content {
                  minutes = replication_time.value.minutes
                }
              }
            }

          }

          dynamic "metrics" {
            for_each = destination.value.metrics != null ? [destination.value.metrics] : []

            content {
              # Valid values: "Enabled" or "Disabled"
              status = metrics.value.status == null ? "Disabled" : try(tobool(metrics.value.status) ? "Enabled" : "Disabled", title(lower(metrics.value.status)))

              dynamic "event_threshold" {
                for_each = metrics.value.minutes != null ? [metrics.value.minutes] : []

                content {
                  minutes = metrics.value.minutes
                }
              }
            }
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.source_selection_criteria != null ? [rule.value.source_selection_criteria] : []

        content {
          dynamic "replica_modifications" {
            for_each = source_selection_criteria.value.replica_modifications == null ? [] : compact([source_selection_criteria.value.replica_modifications.enabled != null ? source_selection_criteria.value.replica_modifications.enabled : source_selection_criteria.value.replica_modifications.status])

            content {
              # Valid values: "Enabled" or "Disabled"
              status = try(tobool(replica_modifications.value) ? "Enabled" : "Disabled", title(lower(replica_modifications.value)), "Disabled")
            }
          }

          dynamic "sse_kms_encrypted_objects" {
            for_each = source_selection_criteria.value.sse_kms_encrypted_objects == null ? [] : compact([source_selection_criteria.value.sse_kms_encrypted_objects.enabled != null ? source_selection_criteria.value.sse_kms_encrypted_objects.enabled : source_selection_criteria.value.sse_kms_encrypted_objects.status])

            content {
              # Valid values: "Enabled" or "Disabled"
              status = try(tobool(sse_kms_encrypted_objects.value) ? "Enabled" : "Disabled", title(lower(sse_kms_encrypted_objects.value)), "Disabled")
            }
          }
        }
      }

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = rule.value.filter == null || max(
          length([for k, a in {
            prefix = rule.value.filter.prefix
            tags   = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) == 0 ? [true] : []

        content {
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = rule.value.filter != null && max(
          length([for k, a in {
            prefix = rule.value.filter.prefix
            tags   = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) == 1 ? [rule.value.filter] : []

        content {
          prefix = filter.value.prefix

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : filter.value.tag != null ? filter.value.tag : {}

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = rule.value.filter != null && max(
          length([for k, a in {
            prefix = rule.value.filter.prefix
            tags   = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) > 1 ? [rule.value.filter] : []

        content {
          and {
            prefix = filter.value.prefix
            tags   = filter.value.tags != null ? filter.value.tags : filter.value.tag
          }
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}

################################################################################
# Bucket Policy
################################################################################

resource "aws_s3_bucket_policy" "this" {
  count = local.create_bucket && local.attach_policy ? 1 : 0

  region = var.region

  # Chain resources (s3_bucket -> s3_bucket_public_access_block -> s3_bucket_policy )
  # to prevent "A conflicting conditional operation is currently in progress against this resource."
  # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/7628

  bucket = var.is_directory_bucket ? aws_s3_directory_bucket.this[0].bucket : aws_s3_bucket.this[0].id
  policy = local.policy

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]
}

data "aws_iam_policy_document" "combined" {
  count = local.create_bucket && local.attach_policy ? 1 : 0

  source_policy_documents = compact([
    var.attach_elb_log_delivery_policy ? data.aws_iam_policy_document.elb_log_delivery[0].json : "",
    var.attach_lb_log_delivery_policy ? data.aws_iam_policy_document.lb_log_delivery[0].json : "",
    var.attach_access_log_delivery_policy ? data.aws_iam_policy_document.access_log_delivery[0].json : "",
    var.attach_cloudtrail_log_delivery_policy ? data.aws_iam_policy_document.cloudtrail_log_delivery[0].json : "",
    var.attach_require_latest_tls_policy ? data.aws_iam_policy_document.require_latest_tls[0].json : "",
    var.attach_deny_insecure_transport_policy ? data.aws_iam_policy_document.deny_insecure_transport[0].json : "",
    var.attach_deny_unencrypted_object_uploads ? data.aws_iam_policy_document.deny_unencrypted_object_uploads[0].json : "",
    var.attach_deny_ssec_encrypted_object_uploads ? data.aws_iam_policy_document.deny_ssec_encrypted_object_uploads[0].json : "",
    var.attach_deny_incorrect_kms_key_sse ? data.aws_iam_policy_document.deny_incorrect_kms_key_sse[0].json : "",
    var.attach_deny_incorrect_encryption_headers ? data.aws_iam_policy_document.deny_incorrect_encryption_headers[0].json : "",
    var.attach_inventory_destination_policy || var.attach_analytics_destination_policy ? data.aws_iam_policy_document.inventory_and_analytics_destination_policy[0].json : "",
    var.attach_policy ? var.policy : "",
    var.attach_waf_log_delivery_policy ? data.aws_iam_policy_document.waf_log_delivery[0].json : "",
  ])
}

# AWS Load Balancer access log delivery policy
locals {
  # List of AWS regions where permissions should be granted to the specified Elastic Load Balancing account ID ( https://docs.aws.amazon.com/elasticloadbalancing/latest/application/enable-access-logging.html#attach-bucket-policy )
  elb_service_accounts = {
    us-east-1      = "127311923021"
    us-east-2      = "033677994240"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
    af-south-1     = "098369216593"
    ap-east-1      = "754344448648"
    ap-south-1     = "718504428378"
    ap-northeast-1 = "582318560864"
    ap-northeast-2 = "600734575887"
    ap-northeast-3 = "383597477331"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    ap-southeast-3 = "589379963580"
    ca-central-1   = "985666609251"
    eu-central-1   = "054676820928"
    eu-west-1      = "156460612806"
    eu-west-2      = "652711504416"
    eu-west-3      = "009996457667"
    eu-south-1     = "635631232127"
    eu-north-1     = "897822967062"
    me-south-1     = "076674570225"
    sa-east-1      = "507241528517"
    us-gov-west-1  = "048591011584"
    us-gov-east-1  = "190560391635"
    cn-north-1     = "638102146993"
    cn-northwest-1 = "037604701340"
  }
}

data "aws_iam_policy_document" "elb_log_delivery" {
  count = local.create_bucket && var.attach_elb_log_delivery_policy && !var.is_directory_bucket ? 1 : 0

  # Policy for AWS Regions created before August 2022 (e.g. US East (N. Virginia), Asia Pacific (Singapore), Asia Pacific (Sydney), Asia Pacific (Tokyo), Europe (Ireland))
  dynamic "statement" {
    for_each = { for k, v in local.elb_service_accounts : k => v if k == local.region }

    content {
      sid = format("ELBRegion%s", title(statement.key))

      principals {
        type        = "AWS"
        identifiers = [format("arn:%s:iam::%s:root", local.partition, statement.value)]
      }

      effect = "Allow"

      actions = [
        "s3:PutObject",
      ]

      resources = [
        "${aws_s3_bucket.this[0].arn}/*",
      ]
    }
  }

  # Policy for AWS Regions created after August 2022 (e.g. Asia Pacific (Hyderabad), Asia Pacific (Melbourne), Europe (Spain), Europe (Zurich), Middle East (UAE))
  statement {
    sid = ""

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*",
    ]
  }
}

# Network Load Balancer access logs
data "aws_iam_policy_document" "lb_log_delivery" {
  count = local.create_bucket && var.attach_lb_log_delivery_policy && !var.is_directory_bucket ? 1 : 0

  statement {
    sid = "AlbNlbLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    dynamic "condition" {
      for_each = length(var.lb_log_delivery_policy_source_organizations) > 0 ? [true] : []

      content {
        test     = "StringEquals"
        variable = "aws:ResourceOrgID"
        values   = var.lb_log_delivery_policy_source_organizations
      }
    }
  }

  statement {
    sid = "AlbNlbLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.this[0].arn,
    ]

    dynamic "condition" {
      for_each = length(var.lb_log_delivery_policy_source_organizations) > 0 ? [true] : []

      content {
        test     = "StringEquals"
        variable = "aws:ResourceOrgID"
        values   = var.lb_log_delivery_policy_source_organizations
      }
    }
  }
}

# Grant access to S3 log delivery group for server access logging
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-ownership-migrating-acls-prerequisites.html#object-ownership-server-access-logs
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/enable-server-access-logging.html#grant-log-delivery-permissions-general
data "aws_iam_policy_document" "access_log_delivery" {
  count = local.create_bucket && var.attach_access_log_delivery_policy && !var.is_directory_bucket ? 1 : 0

  statement {
    sid = "AWSAccessLogDeliveryWrite"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*",
    ]

    dynamic "condition" {
      for_each = length(var.access_log_delivery_policy_source_buckets) != 0 ? [true] : []
      content {
        test     = "ForAnyValue:ArnLike"
        variable = "aws:SourceArn"
        values   = var.access_log_delivery_policy_source_buckets
      }
    }

    dynamic "condition" {
      for_each = length(var.access_log_delivery_policy_source_accounts) != 0 ? [true] : []
      content {
        test     = "ForAnyValue:StringEquals"
        variable = "aws:SourceAccount"
        values   = var.access_log_delivery_policy_source_accounts
      }
    }

    dynamic "condition" {
      for_each = length(var.access_log_delivery_policy_source_organizations) > 0 ? [true] : []

      content {
        test     = "StringEquals"
        variable = "aws:ResourceOrgID"
        values   = var.access_log_delivery_policy_source_organizations
      }
    }

  }

  statement {
    sid = "AWSAccessLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this[0].arn,
    ]

    dynamic "condition" {
      for_each = length(var.access_log_delivery_policy_source_organizations) > 0 ? [true] : []

      content {
        test     = "StringEquals"
        variable = "aws:ResourceOrgID"
        values   = var.access_log_delivery_policy_source_organizations
      }
    }

  }
}

#WAF
data "aws_iam_policy_document" "waf_log_delivery" {
  count = local.create_bucket && var.attach_waf_log_delivery_policy && !var.is_directory_bucket ? 1 : 0

  statement {
    sid = "WafLogDeliveryWrite"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/AWSLogs/${local.account_id}/*",
    ]

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }

    condition {
      test     = "StringEquals"
      values   = [local.account_id]
      variable = "aws:SourceAccount"
    }

    condition {
      test     = "ArnLike"
      values   = ["arn:${local.partition}:logs:*:${local.account_id}:*"]
      variable = "aws:SourceArn"
    }
  }

  statement {
    sid = "WafLogDeliveryAclCheck"

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      aws_s3_bucket.this[0].arn,
    ]

    condition {
      test     = "StringEquals"
      values   = [local.account_id]
      variable = "aws:SourceAccount"
    }

    condition {
      test     = "ArnLike"
      values   = ["arn:${local.partition}:logs:*:${local.account_id}:*"]
      variable = "aws:SourceArn"
    }
  }
}

# CloudTrail
data "aws_iam_policy_document" "cloudtrail_log_delivery" {
  count = local.create_bucket && var.attach_cloudtrail_log_delivery_policy && !var.is_directory_bucket ? 1 : 0

  statement {
    sid = "AWSCloudTrailAclCheck"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl",
    ]
    resources = [
      aws_s3_bucket.this[0].arn,
    ]
  }

  statement {
    sid = "AWSCloudTrailWrite"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.this[0].arn}/AWSLogs/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

data "aws_iam_policy_document" "deny_insecure_transport" {
  count = local.create_bucket && var.attach_deny_insecure_transport_policy && !var.is_directory_bucket ? 1 : 0

  statement {
    sid    = "denyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this[0].arn,
      "${aws_s3_bucket.this[0].arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values = [
        "false"
      ]
    }
  }
}

data "aws_iam_policy_document" "require_latest_tls" {
  count = local.create_bucket && var.attach_require_latest_tls_policy && !var.is_directory_bucket ? 1 : 0

  statement {
    sid    = "denyOutdatedTLS"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      aws_s3_bucket.this[0].arn,
      "${aws_s3_bucket.this[0].arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values = [
        "1.2"
      ]
    }
  }
}

data "aws_iam_policy_document" "deny_incorrect_encryption_headers" {
  count = local.create_bucket && var.attach_deny_incorrect_encryption_headers && !var.is_directory_bucket ? 1 : 0

  statement {
    sid    = "denyIncorrectEncryptionHeaders"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = try(var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm, null) == "aws:kms" ? ["aws:kms"] : ["AES256"]
    }
  }
}

data "aws_iam_policy_document" "deny_incorrect_kms_key_sse" {
  count = local.create_bucket && var.attach_deny_incorrect_kms_key_sse && !var.is_directory_bucket ? 1 : 0

  statement {
    sid    = "denyIncorrectKmsKeySse"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
      values   = [var.allowed_kms_key_arn]
    }
  }
}

data "aws_iam_policy_document" "deny_unencrypted_object_uploads" {
  count = local.create_bucket && var.attach_deny_unencrypted_object_uploads && !var.is_directory_bucket ? 1 : 0

  statement {
    sid    = "denyUnencryptedObjectUploads"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"
      values   = [true]
    }
  }
}

data "aws_iam_policy_document" "deny_ssec_encrypted_object_uploads" {
  count = local.create_bucket && var.attach_deny_ssec_encrypted_object_uploads && !var.is_directory_bucket ? 1 : 0

  statement {
    sid    = "denySSECEncryptedObjectUploads"
    effect = "Deny"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*"
    ]

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption-customer-algorithm"
      values   = [false]
    }
  }
}

################################################################################
# Public Access Block
################################################################################

resource "aws_s3_bucket_public_access_block" "this" {
  count = local.create_bucket && var.attach_public_policy && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket = aws_s3_bucket.this[0].id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  skip_destroy            = var.skip_destroy_public_access_block
}

################################################################################
# Ownership Controls
################################################################################

resource "aws_s3_bucket_ownership_controls" "this" {
  count = local.create_bucket && var.control_object_ownership && !var.is_directory_bucket ? 1 : 0

  region = var.region

  bucket = local.attach_policy ? aws_s3_bucket_policy.this[0].id : aws_s3_bucket.this[0].id

  rule {
    object_ownership = var.object_ownership
  }

  # This `depends_on` is to prevent "A conflicting conditional operation is currently in progress against this resource."
  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket.this
  ]
}

################################################################################
# Intelligent Tiering
################################################################################

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = { for k, v in local.intelligent_tiering : k => v if local.create_bucket && !var.is_directory_bucket }

  region = var.region

  name   = each.key
  bucket = aws_s3_bucket.this[0].id
  status = try(tobool(each.value.status) ? "Enabled" : "Disabled", title(lower(each.value.status)), null)

  # Max 1 block - filter
  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "tiering" {
    for_each = each.value.tiering

    content {
      access_tier = tiering.key
      days        = tiering.value.days
    }
  }

}

################################################################################
# Metric(s)
################################################################################

resource "aws_s3_bucket_metric" "this" {
  for_each = { for k, v in var.metric_configuration : k => v if local.create_bucket }

  region = var.region

  name   = each.value.name
  bucket = var.is_directory_bucket ? aws_s3_directory_bucket.this[0].bucket : aws_s3_bucket.this[0].id

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix       = filter.value.prefix
      tags         = var.is_directory_bucket ? null : filter.value.tags
      access_point = filter.value.access_point
    }
  }
}

################################################################################
# Inventory
################################################################################

resource "aws_s3_bucket_inventory" "this" {
  for_each = { for k, v in var.inventory_configuration : k => v if local.create_bucket }

  region = var.region

  name                     = each.key
  bucket                   = each.value.bucket != null ? each.value.bucket : (var.is_directory_bucket ? aws_s3_directory_bucket.this[0].bucket : aws_s3_bucket.this[0].id)
  included_object_versions = each.value.included_object_versions
  enabled                  = each.value.enabled
  optional_fields          = each.value.optional_fields

  destination {
    bucket {
      bucket_arn = each.value.destination.bucket_arn != null ? each.value.destination.bucket_arn : try(aws_s3_bucket.this[0].arn, null)
      format     = each.value.destination.format
      account_id = each.value.destination.account_id
      prefix     = each.value.destination.prefix

      dynamic "encryption" {
        for_each = each.value.destination.encryption != null ? [each.value.destination.encryption] : []

        content {

          dynamic "sse_kms" {
            for_each = encryption.value.encryption_type == "sse_kms" ? [true] : []

            content {
              key_id = encryption.value.kms_key_id
            }
          }

          dynamic "sse_s3" {
            for_each = encryption.value.encryption_type == "sse_s3" ? [true] : []

            content {
            }
          }
        }
      }
    }
  }

  schedule {
    frequency = each.value.frequency
  }

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix = filter.value.prefix
    }
  }
}

# Inventory and analytics destination bucket requires a bucket policy to allow source to PutObjects
# https://docs.aws.amazon.com/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-use-case-9
data "aws_iam_policy_document" "inventory_and_analytics_destination_policy" {
  count = local.create_bucket && !var.is_directory_bucket && (var.attach_inventory_destination_policy || var.attach_analytics_destination_policy) ? 1 : 0

  statement {
    sid    = "destinationInventoryAndAnalyticsPolicy"
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.this[0].arn}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = compact(distinct([
        var.inventory_self_source_destination ? aws_s3_bucket.this[0].arn : var.inventory_source_bucket_arn,
        var.analytics_self_source_destination ? aws_s3_bucket.this[0].arn : var.analytics_source_bucket_arn
      ]))
    }

    condition {
      test = "StringEquals"
      values = compact(distinct([
        var.inventory_self_source_destination ? local.account_id : var.inventory_source_account_id,
        var.analytics_self_source_destination ? local.account_id : var.analytics_source_account_id
      ]))
      variable = "aws:SourceAccount"
    }

    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}

################################################################################
# Analytics
################################################################################

resource "aws_s3_bucket_analytics_configuration" "this" {
  for_each = { for k, v in var.analytics_configuration : k => v if local.create_bucket && !var.is_directory_bucket }

  region = var.region

  bucket = aws_s3_bucket.this[0].id
  name   = each.key

  dynamic "filter" {
    for_each = each.value.filter != null ? [each.value.filter] : []

    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "storage_class_analysis" {
    for_each = each.value.storage_class_analysis != null ? [each.value.storage_class_analysis] : []

    content {

      data_export {
        output_schema_version = storage_class_analysis.value.output_schema_version

        destination {

          s3_bucket_destination {
            bucket_arn        = storage_class_analysis.value.destination_bucket_arn != null ? storage_class_analysis.value.destination_bucket_arn : try(aws_s3_bucket.this[0].arn, null)
            bucket_account_id = coalesce(storage_class_analysis.value.destination_account_id, local.account_id)
            format            = coalesce(storage_class_analysis.value.export_format, "CSV")
            prefix            = storage_class_analysis.value.export_prefix
          }
        }
      }
    }
  }
}

################################################################################
# Metadata
################################################################################

resource "aws_s3_bucket_metadata_configuration" "this" {
  count = local.create_bucket && var.create_metadata_configuration ? 1 : 0

  bucket = aws_s3_bucket.this[0].bucket
  region = var.region

  metadata_configuration {
    inventory_table_configuration {
      configuration_state = var.metadata_inventory_table_configuration_state

      dynamic "encryption_configuration" {
        for_each = var.metadata_encryption_configuration != null ? [var.metadata_encryption_configuration] : []
        content {
          kms_key_arn   = encryption_configuration.value.kms_key_arn
          sse_algorithm = encryption_configuration.value.sse_algorithm
        }
      }
    }

    journal_table_configuration {
      record_expiration {
        days       = var.metadata_journal_table_record_expiration_days
        expiration = var.metadata_journal_table_record_expiration
      }
    }
  }
}

################################################################################
# File System(s)
################################################################################

locals {
  # S3 Files supports general purpose buckets only
  file_systems = { for k, v in var.file_systems : k => v if local.create_bucket && !var.is_directory_bucket && v.create }
}

resource "aws_s3files_file_system" "this" {
  for_each = local.file_systems

  region = var.region

  bucket                = aws_s3_bucket.this[0].arn
  prefix                = each.value.prefix
  role_arn              = each.value.create_iam_role ? aws_iam_role.file_system[each.key].arn : each.value.iam_role_arn
  kms_key_id            = each.value.kms_key_id
  accept_bucket_warning = each.value.accept_bucket_warning

  tags = merge(
    var.tags,
    { Name = coalesce(each.value.name, each.key) },
    each.value.tags
  )

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }

  depends_on = [
    # S3 Files requires versioning, and the file system must be deleted before versioning is suspended
    aws_s3_bucket_versioning.this,
    # The role has to be able to reach the bucket for as long as the file system exists
    aws_iam_role_policy.file_system,
  ]
}

################################################################################
# File System IAM Role(s)
################################################################################

locals {
  file_system_iam_roles = { for k, v in local.file_systems : k => v if v.create_iam_role }
}

data "aws_service_principal" "elasticfilesystem" {
  count = length(local.file_system_iam_roles) > 0 ? 1 : 0

  service_name = "elasticfilesystem"
  region       = local.region
}

data "aws_iam_policy_document" "file_system_assume_role" {
  count = length(local.file_system_iam_roles) > 0 ? 1 : 0

  statement {
    sid     = "AllowS3FilesAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [data.aws_service_principal.elasticfilesystem[0].name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    # The role exists before its file system, so the trust cannot name one file system
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${local.partition}:s3files:${local.region}:${local.account_id}:file-system/*"]
    }
  }
}

resource "aws_iam_role" "file_system" {
  for_each = local.file_system_iam_roles

  name        = each.value.iam_role_use_name_prefix ? null : coalesce(each.value.iam_role_name, "${coalesce(each.value.name, each.key)}-s3files")
  name_prefix = each.value.iam_role_use_name_prefix ? "${coalesce(each.value.iam_role_name, "${coalesce(each.value.name, each.key)}-s3files")}-" : null
  path        = each.value.iam_role_path
  description = each.value.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.file_system_assume_role[0].json
  permissions_boundary  = each.value.iam_role_permissions_boundary
  force_detach_policies = true

  tags = merge(var.tags, each.value.iam_role_tags)
}

data "aws_iam_policy_document" "file_system" {
  for_each = local.file_system_iam_roles

  statement {
    sid = "S3BucketPermissions"
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
    ]
    resources = [aws_s3_bucket.this[0].arn]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "S3ObjectPermissions"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject*",
      "s3:GetObject*",
      "s3:List*",
      "s3:PutObject*",
    ]
    resources = ["${aws_s3_bucket.this[0].arn}/${each.value.prefix != null ? each.value.prefix : ""}*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceAccount"
      values   = [local.account_id]
    }
  }

  statement {
    sid = "UseKmsKeyWithS3Files"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
    ]
    resources = ["arn:${local.partition}:kms:${local.region}:${local.account_id}:*"]

    condition {
      test     = "StringLike"
      variable = "kms:ViaService"
      values   = ["s3.${local.region}.${local.dns_suffix}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:s3:arn"
      values = [
        aws_s3_bucket.this[0].arn,
        "${aws_s3_bucket.this[0].arn}/${each.value.prefix != null ? each.value.prefix : ""}*",
      ]
    }
  }

  # S3 Files manages its own EventBridge rule to detect changes in the bucket
  statement {
    sid = "EventBridgeManage"
    actions = [
      "events:DeleteRule",
      "events:DisableRule",
      "events:EnableRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
    resources = ["arn:${local.partition}:events:*:*:rule/DO-NOT-DELETE-S3-Files*"]

    condition {
      test     = "StringEquals"
      variable = "events:ManagedBy"
      values   = [data.aws_service_principal.elasticfilesystem[0].name]
    }
  }

  statement {
    sid = "EventBridgeRead"
    actions = [
      "events:DescribeRule",
      "events:ListRuleNamesByTarget",
      "events:ListRules",
      "events:ListTargetsByRule",
    ]
    resources = ["arn:${local.partition}:events:*:*:rule/*"]
  }
}

resource "aws_iam_role_policy" "file_system" {
  for_each = local.file_system_iam_roles

  name   = "S3Files"
  role   = aws_iam_role.file_system[each.key].id
  policy = data.aws_iam_policy_document.file_system[each.key].json
}

################################################################################
# File System Mount Target(s)
################################################################################

locals {
  file_system_mount_targets = {
    for mt in flatten([
      for fs_key, fs in local.file_systems : [
        for mt_key, mt in fs.mount_targets : merge(mt, {
          file_system_key  = fs_key
          mount_target_key = mt_key
          security_groups  = fs.security_groups
        })
      ]
    ]) : "${mt.file_system_key}/${mt.mount_target_key}" => mt
  }
}

resource "aws_s3files_mount_target" "this" {
  for_each = local.file_system_mount_targets

  region = var.region

  file_system_id  = aws_s3files_file_system.this[each.value.file_system_key].id
  subnet_id       = each.value.subnet_id
  ip_address_type = each.value.ip_address_type
  ipv4_address    = each.value.ipv4_address
  ipv6_address    = each.value.ipv6_address
  security_groups = each.value.security_groups != null ? each.value.security_groups : (local.create_file_system_security_group ? [aws_security_group.file_system[0].id] : null)

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }
}

################################################################################
# File System Security Group
################################################################################

locals {
  # Only created when at least one mount target relies on it rather than on its file system's own groups
  create_file_system_security_group = var.create_file_system_security_group && anytrue([for mt in values(local.file_system_mount_targets) : mt.security_groups == null])

  file_system_security_group_name = var.file_system_security_group_name != null ? var.file_system_security_group_name : "${try(aws_s3_bucket.this[0].id, "")}-s3files"
}

resource "aws_security_group" "file_system" {
  count = local.create_file_system_security_group ? 1 : 0

  region = var.region

  name        = var.file_system_security_group_use_name_prefix ? null : local.file_system_security_group_name
  name_prefix = var.file_system_security_group_use_name_prefix ? "${local.file_system_security_group_name}-" : null
  description = var.file_system_security_group_description

  revoke_rules_on_delete = true
  vpc_id                 = var.file_system_security_group_vpc_id

  tags = merge(
    var.tags,
    { Name = local.file_system_security_group_name },
    var.file_system_security_group_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "file_system" {
  for_each = { for k, v in var.file_system_security_group_ingress_rules : k => v if local.create_file_system_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.file_system[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.file_system[0].id
  to_port                      = each.value.to_port

  tags = merge(
    var.tags,
    { Name = coalesce(each.value.name, "${local.file_system_security_group_name}-${each.key}") },
    each.value.tags
  )
}

resource "aws_vpc_security_group_egress_rule" "file_system" {
  for_each = { for k, v in var.file_system_security_group_egress_rules : k => v if local.create_file_system_security_group }

  region = var.region

  cidr_ipv4                    = each.value.cidr_ipv4
  cidr_ipv6                    = each.value.cidr_ipv6
  description                  = each.value.description
  from_port                    = each.value.from_port
  ip_protocol                  = each.value.ip_protocol
  prefix_list_id               = each.value.prefix_list_id
  referenced_security_group_id = each.value.referenced_security_group_id == "self" ? aws_security_group.file_system[0].id : each.value.referenced_security_group_id
  security_group_id            = aws_security_group.file_system[0].id
  to_port                      = each.value.to_port

  tags = merge(
    var.tags,
    { Name = coalesce(each.value.name, "${local.file_system_security_group_name}-${each.key}") },
    each.value.tags
  )
}

################################################################################
# File System Access Point(s)
################################################################################

locals {
  file_system_access_points = {
    for ap in flatten([
      for fs_key, fs in local.file_systems : [
        for ap_key, ap in fs.access_points : merge(ap, {
          file_system_key  = fs_key
          access_point_key = ap_key
        })
      ]
    ]) : "${ap.file_system_key}/${ap.access_point_key}" => ap
  }
}

resource "aws_s3files_access_point" "this" {
  for_each = local.file_system_access_points

  region = var.region

  file_system_id = aws_s3files_file_system.this[each.value.file_system_key].id

  dynamic "posix_user" {
    for_each = each.value.posix_user != null ? [each.value.posix_user] : []

    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = posix_user.value.secondary_gids
    }
  }

  dynamic "root_directory" {
    for_each = each.value.root_directory != null ? [each.value.root_directory] : []

    content {
      path = root_directory.value.path

      dynamic "creation_permissions" {
        for_each = root_directory.value.creation_permissions != null ? [root_directory.value.creation_permissions] : []

        content {
          owner_gid   = creation_permissions.value.owner_gid
          owner_uid   = creation_permissions.value.owner_uid
          permissions = creation_permissions.value.permissions
        }
      }
    }
  }

  tags = merge(
    var.tags,
    { Name = coalesce(each.value.name, each.value.access_point_key) },
    each.value.tags
  )

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []

    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
    }
  }
}

################################################################################
# File System Policy
################################################################################

locals {
  # Actions each access level grants through an access point
  file_system_access_point_actions = {
    read       = ["s3files:ClientMount"]
    read_write = ["s3files:ClientMount", "s3files:ClientWrite"]
  }

  # One entry per access point and access level that names principals
  file_system_access_point_grants = flatten([
    for ap_key, ap in local.file_system_access_points : [
      for level, principals in { read = ap.read_access_arns, read_write = ap.read_write_access_arns } : {
        file_system_key               = ap.file_system_key
        access_point                  = ap_key
        actions                       = local.file_system_access_point_actions[level]
        principals                    = principals
      } if try(length(principals), 0) > 0
    ]
  ])

  # A policy exists whenever the caller sets statements or lists principals on an access point, so neither is silently
  # ignored. Presence is tested rather than length, which is unknown at plan time for a list built from computed values
  file_system_policies = {
    for k, v in local.file_systems : k => v
    if v.policy_statements != null || anytrue([for ap in values(v.access_points) : ap.read_access_arns != null || ap.read_write_access_arns != null])
  }
}

data "aws_iam_policy_document" "file_system_policy" {
  for_each = local.file_system_policies

  dynamic "statement" {
    for_each = each.value.policy_statements != null ? each.value.policy_statements : []

    content {
      sid           = statement.value.sid
      actions       = statement.value.actions
      not_actions   = statement.value.not_actions
      effect        = statement.value.effect
      resources     = statement.value.resources != null || statement.value.not_resources != null ? statement.value.resources : [aws_s3files_file_system.this[each.key].arn]
      not_resources = statement.value.not_resources

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : []

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = statement.value.not_principals != null ? statement.value.not_principals : []

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = statement.value.conditions != null ? statement.value.conditions : []

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }

  # Allow each listed principal through its access point
  dynamic "statement" {
    for_each = [for g in local.file_system_access_point_grants : g if g.file_system_key == each.key]

    content {
      effect    = "Allow"
      actions   = statement.value.actions
      resources = [aws_s3files_file_system.this[each.key].arn]

      principals {
        type        = "AWS"
        identifiers = statement.value.principals
      }

      condition {
        test     = "StringEquals"
        variable = "s3files:AccessPointArn"
        values   = [aws_s3files_access_point.this[statement.value.access_point].arn]
      }
    }
  }

  # Deny each listed principal through every other access point. An allow alone does not restrict,
  # because allows are additive across identity and resource policies
  dynamic "statement" {
    for_each = {
      for pair in flatten([
        for g in local.file_system_access_point_grants : [
          for principal in g.principals : { principal = principal, access_point = g.access_point }
        ] if g.file_system_key == each.key
      ]) : pair.principal => pair.access_point...
    }

    content {
      effect    = "Deny"
      actions   = ["s3files:Client*"]
      resources = [aws_s3files_file_system.this[each.key].arn]

      principals {
        type        = "AWS"
        identifiers = [statement.key]
      }

      condition {
        test     = "StringNotEquals"
        variable = "s3files:AccessPointArn"
        values   = [for ap in distinct(statement.value) : aws_s3files_access_point.this[ap].arn]
      }
    }
  }
}

resource "aws_s3files_file_system_policy" "this" {
  for_each = local.file_system_policies

  region = var.region

  file_system_id = aws_s3files_file_system.this[each.key].id
  policy         = data.aws_iam_policy_document.file_system_policy[each.key].json
}

################################################################################
# File System Synchronization Configuration(s)
################################################################################

resource "aws_s3files_synchronization_configuration" "this" {
  for_each = { for k, v in local.file_systems : k => v.synchronization_configuration if v.synchronization_configuration != null }

  region = var.region

  file_system_id = aws_s3files_file_system.this[each.key].id

  dynamic "import_data_rule" {
    for_each = each.value.import_data_rule

    content {
      prefix         = import_data_rule.value.prefix
      size_less_than = import_data_rule.value.size_less_than
      trigger        = import_data_rule.value.trigger
    }
  }

  expiration_data_rule {
    days_after_last_access = each.value.expiration_data_rule.days_after_last_access
  }
}
