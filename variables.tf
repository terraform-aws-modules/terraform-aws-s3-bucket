variable "bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  default     = null
}

variable "bucket_prefix" {
  description = "(Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket."
  default     = null
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

variable "policy" {
  description = "(Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide."
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  default     = {}
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  default     = false
}

variable "acceleration_status" {
  description = "(Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended."
  default     = null
}

variable "region" {
  description = "(Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee."
  default     = null
}

variable "request_payer" {
  description = "(Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information."
  default     = null
}

variable "website_inputs" {
  type = list(object({
    index_document           = string
    error_document           = string
    redirect_all_requests_to = string
    routing_rules            = string
  }))
  default = null
}

variable "cors_rule_inputs" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = null
}

variable "versioning_inputs" {
  type = list(object({
    enabled    = string
    mfa_delete = string
  }))
  default = null
}

variable "logging_inputs" {
  type = list(object({
    target_bucket = string
    target_prefix = string
  }))
  default = null
}

// Lifecycle rules variables:
variable "lifecycle_rule_inputs" {
  type = list(object({
    id                                     = string
    prefix                                 = string
    tags                                   = map(string)
    enabled                                = string
    abort_incomplete_multipart_upload_days = string
    expiration_inputs = list(object({
      date                         = string
      days                         = number
      expired_object_delete_marker = string
    }))
    transition_inputs = list(object({
      date          = string
      days          = number
      storage_class = string
    }))
    noncurrent_version_transition_inputs = list(object({
      days          = number
      storage_class = string
    }))
    noncurrent_version_expiration_inputs = list(object({
      days = number
    }))
  }))
  default = null
}

// Replication configuration variables:
variable "replication_configuration_inputs" {
  type = list(object({
    role = string
    rules_inputs = list(object({
      id = string
      //  priority                           = number
      prefix = string
      status = string
      destination_inputs = list(object({
        bucket             = string
        storage_class      = string
        replica_kms_key_id = string
        account_id         = string
        access_control_translation_inputs = list(object({
          owner = string
        }))
      }))
      source_selection_criteria_inputs = list(object({
        enabled = string
      }))
      /*  filter_inputs                      = list(object({
          prefix                           = string
          tags                             = map(string)
        }))
      */
    }))
  }))
  default = null
}


// Server side encryption config:
variable "server_side_encryption_configuration_inputs" {
  type = list(object({
    sse_algorithm     = string
    kms_master_key_id = string
  }))
  default = null
}

//Object lock config
/*
variable "object_lock_configuration_inputs" {
  type                           = list(object({
    object_lock_enabled          = string 
    rule_inputs                  = list(object({
      mode                       = string 
      days                       = number
      years                      = number
    }))
  }))     
  default = null
}
*/

