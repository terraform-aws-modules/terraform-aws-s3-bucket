variable "create" {
  description = "Whether to create s3 table resources"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
  default     = {}
}

################################################################################
# Table Bucket
################################################################################

variable "table_bucket_name" {
  description = "Name of the table bucket. Must be between 3 and 63 characters in length. Can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number"
  type        = string
  default     = null
}

variable "encryption_configuration" {
  description = "Encryption configuration for the table bucket"
  type = object({
    kms_key_arn   = optional(string)
    sse_algorithm = optional(string)
  })
  default = null
}

variable "maintenance_configuration" {
  description = "Maintenance configuration for the table bucket"
  type = object({
    iceberg_unreferenced_file_removal = optional(object({
      settings = optional(object({
        non_current_days  = optional(number)
        unreferenced_days = optional(number)
      }))
      status = optional(string)
    }))
  })
  default = null
}

################################################################################
# Table Bucket Policy
################################################################################

variable "create_table_bucket_policy" {
  description = "Whether to create s3 table bucket policy"
  type        = bool
  default     = false
}

variable "table_bucket_policy" {
  description = "Amazon Web Services resource-based policy document in JSON format"
  type        = string
  default     = null
}

variable "table_bucket_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "table_bucket_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "table_bucket_policy_statements" {
  description = "A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage"
  type = list(object({
    sid           = optional(string)
    actions       = optional(list(string))
    not_actions   = optional(list(string))
    effect        = optional(string)
    resources     = optional(list(string))
    not_resources = optional(list(string))
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    not_principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })))
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })))
  }))
  default = []
}

################################################################################
# Table(s)
################################################################################

variable "tables" {
  description = "Map of table configurations"
  type = map(object({
    table_name = optional(string)
    namespace  = string
    format     = string
    tags       = optional(map(string), {})

    encryption_configuration = optional(object({
      kms_key_arn   = optional(string)
      sse_algorithm = optional(string)
    }))
    maintenance_configuration = optional(object({
      iceberg_compaction = optional(object({
        settings = optional(object({
          target_file_size_mb = optional(number)
        }))
        status = optional(string)
      }))
      iceberg_snapshot_management = optional(object({
        settings = optional(object({
          max_snapshot_age_hours = optional(number)
          min_snapshots_to_keep  = optional(number)
        }))
        status = optional(string)
      }))
    }))
    metadata = optional(object({
      iceberg = optional(object({
        schema = optional(object({
          field = optional(map(object({
            name     = optional(string)
            type     = string
            required = optional(bool)
          })), {})
        }))
      }))
    }))

    create_table_policy = optional(bool, false)
    policy_statements = optional(list(object({
      sid           = optional(string)
      actions       = optional(list(string))
      not_actions   = optional(list(string))
      effect        = optional(string)
      resources     = optional(list(string))
      not_resources = optional(list(string))
      principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      not_principals = optional(list(object({
        type        = string
        identifiers = list(string)
      })))
      conditions = optional(list(object({
        test     = string
        values   = list(string)
        variable = string
      })))
    })), [])
  }))
  default = {}
}
