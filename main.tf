resource "aws_s3_bucket" "this" {
  bucket              = var.bucket
  bucket_prefix       = var.bucket_prefix
  acl                 = var.acl
  policy              = var.policy
  tags                = var.tags
  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  region              = var.region
  request_payer       = var.request_payer

  dynamic "website" {
    for_each = var.website_inputs == null ? [] : var.website_inputs

    content {
      index_document           = website.value.index_document
      error_document           = website.value.error_document
      redirect_all_requests_to = website.value.redirect_all_requests_to
      routing_rules            = website.value.routing_rules
    }
  }

  dynamic "cors_rule" {
    for_each = var.cors_rule_inputs == null ? [] : var.cors_rule_inputs

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

  dynamic "versioning" {
    for_each = var.versioning_inputs == null ? [] : var.versioning_inputs

    content {
      enabled    = versioning.value.enabled
      mfa_delete = versioning.value.mfa_delete
    }
  }


  dynamic "logging" {
    for_each = var.logging_inputs == null ? [] : var.logging_inputs

    content {
      target_bucket = logging.value.target_bucket
      target_prefix = logging.value.target_prefix
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule_inputs == null ? [] : var.lifecycle_rule_inputs

    content {
      id                                     = lifecycle_rule.value.id
      prefix                                 = lifecycle_rule.value.prefix
      tags                                   = lifecycle_rule.value.tags
      enabled                                = lifecycle_rule.value.enabled
      abort_incomplete_multipart_upload_days = lifecycle_rule.value.abort_incomplete_multipart_upload_days

      dynamic "expiration" {
        for_each = lifecycle_rule.value.expiration_inputs == null ? [] : lifecycle_rule.value.expiration_inputs

        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "transition" {
        for_each = lifecycle_rule.value.transition_inputs == null ? [] : lifecycle_rule.value.transition_inputs

        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lifecycle_rule.value.noncurrent_version_transition_inputs == null ? [] : lifecycle_rule.value.noncurrent_version_transition_inputs

        content {
          days          = noncurrent_version_transition.value.days
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.noncurrent_version_expiration_inputs == null ? [] : lifecycle_rule.value.noncurrent_version_expiration_inputs

        content {
          days = noncurrent_version_expiration.value.days
        }
      }
    }
  }

  dynamic "replication_configuration" {
    for_each = var.replication_configuration_inputs == null ? [] : var.replication_configuration_inputs

    content {
      role = replication_configuration.value.role
      dynamic "rules" {
        for_each = replication_configuration.value.rules_inputs == null ? [] : replication_configuration.value.rules_inputs

        content {
          id = rules.value.id
          // priority                 = rules.value.priority
          prefix = rules.value.prefix
          status = rules.value.status

          dynamic "destination" {
            for_each = rules.value.destination_inputs == null ? [] : rules.value.destination_inputs

            content {
              bucket             = destination.value.bucket
              storage_class      = destination.value.storage_class
              replica_kms_key_id = destination.value.replica_kms_key_id
              account_id         = destination.value.account_id

              dynamic "access_control_translation" {
                for_each = destination.value.access_control_translation_inputs == null ? [] : destination.value.access_control_translation_inputs

                content {
                  owner = access_control_translation.value.owner
                }
              }
            }
          }

          dynamic "source_selection_criteria" {
            for_each = rules.value.source_selection_criteria_inputs == null ? [] : rules.value.source_selection_criteria_inputs

            content {
              sse_kms_encrypted_objects {
                enabled = source_selection_criteria.value.enabled
              }
            }
          }
          /*
                     dynamic "filter" {
                         for_each = rules.value.filter_inputs == null ? [] : rules.value.filter_inputs

                         content {
                             prefix                            = filter.value.prefix
                             tags                              = filter.value.tags
                         }
                     }
                     */
        }
      }
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = var.server_side_encryption_configuration_inputs == null ? [] : var.server_side_encryption_configuration_inputs

    content {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = server_side_encryption_configuration.value.sse_algorithm
          kms_master_key_id = server_side_encryption_configuration.value.kms_master_key_id
        }
      }
    }
  }
  /*
    dynamic "object_lock_configuration" {
        for_each = var.object_lock_configuration_inputs == null ? [] : var.object_lock_configuration_inputs

        content {
            object_lock_enabled                          = object_lock_configuration.value.object_lock_enabled
            dynamic "rule" {
                for_each = object_lock_configuration.value.rule_inputs == null ? [] : object_lock_configuration.value.rule_inputs

                content {
                    default_retention {
                            mode                         = rule.value.mode 
                            days                         = rule.value.days
                            years                        = rule.value.years
                    }
                }
            }
        }
    }  
*/
}





