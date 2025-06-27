variable "create" {
  description = "Whether to create s3 table resources"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the region set in the provider configuration"
  type        = string
  default     = null
}

variable "table_bucket_name" {
  description = "Name of the table bucket. Must be between 3 and 63 characters in length. Can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number"
  type        = string
  default     = null
}

variable "encryption_configuration" {
  description = "Map of encryption configurations"
  type        = any
  default     = null
}

variable "maintenance_configuration" {
  description = "Map of table bucket maintenance configurations"
  type        = any
  default     = null
}

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
  type        = any
  default     = {}
}

variable "tables" {
  description = "Map of table configurations"
  type        = any
  default     = {}
}
