variable "create" {
  description = "Whether to create the file system and its associated resources"
  type        = bool
  default     = true
  nullable    = false
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
# File System
################################################################################

variable "name" {
  description = "Name of the file system, used for the `Name` tag and as the prefix of any names this module generates"
  type        = string
  default     = null
}

variable "bucket_arn" {
  description = "ARN of the general purpose bucket the file system is created on"
  type        = string
}

variable "bucket_versioning_status" {
  description = "Versioning status of the bucket. Pass the versioning resource's own attribute, which makes the file system wait for versioning on create and be deleted before it is suspended on destroy"
  type        = string
}

# Changing the prefix, the KMS key or the IAM role (including the created role's name or path)
# replaces the file system, its mount targets and its access points
variable "prefix" {
  description = "Prefix within the bucket the file system is scoped to. The whole bucket when not set"
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "ID of the KMS key used to encrypt the file system. An AWS owned key is used when not set"
  type        = string
  default     = null
}

variable "accept_bucket_warning" {
  description = "Whether to acknowledge the warning AWS raises when the bucket holds enough objects that renaming a prefix is slow"
  type        = bool
  default     = null
}

variable "timeouts" {
  description = "Create and delete timeouts for the file system"
  type = object({
    create = optional(string)
    delete = optional(string)
  })
  default = null
}

################################################################################
# IAM Role
################################################################################

variable "create_iam_role" {
  description = "Whether to create an IAM role for the file system"
  type        = bool
  default     = true
  nullable    = false
}

# A role brought in must already carry its permissions when the file system is created. S3 Files checks
# them at creation, and the file system depends only on the role's ARN, not on any policy attached to it
variable "iam_role_arn" {
  description = "ARN of an existing IAM role for the file system to assume. Used when `create_iam_role` is `false`"
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name of the IAM role created. Falls back to the file system name suffixed with `-s3files`"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Whether to use the IAM role name as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "iam_role_path" {
  description = "Path of the IAM role created"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the IAM role created"
  type        = string
  default     = null
}

variable "iam_role_source_assume_policy_documents" {
  description = "List of IAM policy documents that are merged together into the role's trust policy. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "iam_role_override_assume_policy_documents" {
  description = "List of IAM policy documents that are merged together into the role's trust policy. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "iam_role_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the role's permissions policy. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "iam_role_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the role's permissions policy. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
  nullable    = false
}

variable "iam_role_policies" {
  description = "Policies to attach to the IAM role, keyed by a name of your choosing, valued by the policy ARN"
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "iam_role_kms_key_arns" {
  description = "KMS key ARNs the role may use with S3 Files. Defaults to every key in this account and Region, which is the scope AWS's own policy template uses"
  type        = list(string)
  default     = null
}

variable "iam_role_policy_name" {
  description = "Name of the role's inline permissions policy. Falls back to the role's own name"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role created"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "Additional tags for the IAM role created"
  type        = map(string)
  default     = null
}

################################################################################
# Mount Target(s)
################################################################################

variable "mount_targets" {
  description = "Map of mount targets to create for the file system, keyed by a value known at plan time such as the Availability Zone. One per Availability Zone at most"
  type = map(object({
    subnet_id       = string
    ip_address_type = optional(string)
    ipv4_address    = optional(string)
    ipv6_address    = optional(string)
    security_groups = optional(list(string), [])
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  }))
  default  = {}
  nullable = false
}

variable "security_groups" {
  description = "Security groups added to every mount target, alongside the group this module creates"
  type        = list(string)
  default     = []
  nullable    = false
}

################################################################################
# Security Group
################################################################################

variable "create_security_group" {
  description = "Whether to create a security group for the mount targets"
  type        = bool
  default     = true
  nullable    = false
}

variable "security_group_name" {
  description = "Name of the security group created. Falls back to the file system name suffixed with `-s3files`"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Whether to use the security group name as a prefix"
  type        = bool
  default     = true
  nullable    = false
}

variable "security_group_description" {
  description = "Description of the security group created"
  type        = string
  default     = null
}

variable "security_group_vpc_id" {
  description = "ID of the VPC the security group is created in"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Map of ingress rules to add to the security group. Clients reach a mount target over TCP 2049"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number, 2049)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string))
    to_port                      = optional(number, 2049)
  }))
  default  = {}
  nullable = false
}

variable "security_group_egress_rules" {
  description = "Map of egress rules to add to the security group"
  type = map(object({
    name = optional(string)

    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number)
    ip_protocol                  = string
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string))
    to_port                      = optional(number)
  }))
  default  = {}
  nullable = false
}

variable "security_group_tags" {
  description = "Additional tags for the security group created"
  type        = map(string)
  default     = null
}

################################################################################
# Access Point(s)
################################################################################

variable "access_points" {
  description = "Map of access points to create on the file system. An access point cannot be edited, so any change replaces it"
  type = map(object({
    name = optional(string) # Will fall back to map key
    tags = optional(map(string))

    posix_user = optional(object({
      gid            = number
      uid            = number
      secondary_gids = optional(list(number))
    }))
    root_directory = optional(object({
      path = optional(string)
      creation_permissions = optional(object({
        owner_gid   = number
        owner_uid   = number
        permissions = string
      }))
    }))

    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
    }))

    # A principal listed here is denied every other way into this file system, including mounting without an access point
    read_access_arns       = optional(list(string))
    read_write_access_arns = optional(list(string))
  }))
  default  = {}
  nullable = false
}

################################################################################
# File System Policy
################################################################################

variable "source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the file system policy. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the file system policy. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "create_policy" {
  description = "Whether to create a file system policy. Required for the access point `read_access_arns` and `read_write_access_arns` grants to take effect"
  type        = bool
  default     = false
  nullable    = false
}

variable "policy_statements" {
  description = "List of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) to add to the file system policy"
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
  default = null
}

################################################################################
# Synchronization Configuration
################################################################################

variable "synchronization_configuration" {
  description = "Synchronization configuration for the file system"
  type = object({
    import_data_rule = list(object({
      prefix         = string
      size_less_than = number
      trigger        = string
    }))
    # Required: the API takes exactly one expiration rule with every synchronization configuration
    expiration_data_rule = object({
      days_after_last_access = number
    })
  })
  default = null
}
