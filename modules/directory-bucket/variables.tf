variable "create" {
  description = "Whether to create directory bucket resources"
  type        = bool
  default     = true
}

variable "bucket_name_prefix" {
  description = "Bucket name prefix"
  type        = string
  default     = null
}

variable "data_redundancy" {
  description = "Data redundancy. Valid values: `SingleAvailabilityZone`"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error. These objects are not recoverable"
  type        = bool
  default     = null
}

variable "type" {
  description = "Bucket type. Valid values: `Directory`"
  type        = string
  default     = "Directory"
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

variable "server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type        = any
  default     = {}
}

variable "lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = {}
}

variable "create_bucket_policy" {
  description = "Whether to create a directory bucket policy."
  type        = bool
  default     = false
}

variable "source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s"
  type        = list(string)
  default     = []
}

variable "override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid`"
  type        = list(string)
  default     = []
}

variable "policy_statements" {
  description = "A map of IAM policy statements for custom permission usage"
  type        = any
  default     = {}
}
