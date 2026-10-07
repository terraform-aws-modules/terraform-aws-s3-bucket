variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

variable "create_file_system_policy" {
  description = "Whether to create an s3 files file system policy"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the region set in the provider configuration"
  type        = string
  default     = null
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
  default     = null
}

variable "role_arn" {
  description = "IAM role ARN used by S3 Files to access the S3 bucket"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID where mount targets will be created"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs where mount targets will be created"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to each mount target"
  type        = list(string)
  default     = []
}

variable "ip_address_type" {
  description = "IP address type for mount targets"
  type        = string
  default     = null
}

variable "mount_target_ipv4_addresses" {
  description = "Map of explicit IPv4 addresses for mount targets keyed by subnet ID"
  type        = map(string)
  default     = {}
}

variable "mount_target_ipv6_addresses" {
  description = "Map of explicit IPv6 addresses for mount targets keyed by subnet ID"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  description = "S3 bucket prefix to scope the file system"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "KMS key ID for encrypting data in the file system"
  type        = string
  default     = null
}

variable "accept_bucket_warning" {
  description = "Whether to acknowledge and accept bucket warnings during file system creation"
  type        = bool
  default     = null
}

variable "file_system_policy" {
  description = "Amazon Web Services resource-based policy document in JSON format for the file system. If null, a default policy allowing account-root mount scoped to the provided VPC is created"
  type        = string
  default     = null
}

variable "tags" {
  description = "Key-value map of resource tags"
  type        = map(string)
  default     = {}
}

variable "access_points" {
  description = "Map of S3 Files access point configurations to create"
  type = map(object({
    tags = optional(map(string), {})
    posix_user = object({
      uid            = number
      gid            = number
      secondary_gids = optional(list(number), null)
    })
    root_directory = optional(object({
      path = optional(string, null)
      creation_permissions = optional(object({
        owner_uid   = number
        owner_gid   = number
        permissions = string
      }), null)
    }), null)
  }))
  default = {}
}

variable "synchronization_import_data_rules" {
  description = "Import data rules for S3 Files synchronization. Note: size_less_than is in bytes (131072 bytes = 128KB)."
  type = list(object({
    prefix         = string
    size_less_than = number
    trigger        = string
  }))
  default = [
    {
      prefix         = ""
      size_less_than = 131072
      trigger        = "ON_DIRECTORY_FIRST_ACCESS"
    }
  ]
}

variable "synchronization_expiration_data_rule" {
  description = "Expiration rule for S3 Files synchronization."
  type = object({
    days_after_last_access = number
  })
  default = {
    days_after_last_access = 30
  }
}
