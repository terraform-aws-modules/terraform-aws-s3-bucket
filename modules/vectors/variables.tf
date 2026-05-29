################################################################################
# Vector Bucket
################################################################################

variable "create" {
  description = "Whether to create the S3 Vectors vector bucket"
  type        = bool
  default     = true
}

variable "vector_bucket_name" {
  description = "Name of the S3 Vectors vector bucket"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Boolean that indicates all indexes and vectors should be deleted from the vector bucket when the vector bucket is destroyed"
  type        = bool
  default     = false
}

variable "region" {
  description = "Region where the vector bucket will be managed. Defaults to the region set in the provider configuration"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the vector bucket"
  type        = map(string)
  default     = {}
}

variable "encryption_configuration" {
  description = "Encryption configuration for the vector bucket"
  type = object({
    sse_type    = string
    kms_key_arn = optional(string)
  })
  default = null
}

################################################################################
# Vector Bucket Policy
################################################################################

variable "create_policy" {
  description = "Whether to create the S3 Vectors vector bucket policy"
  type        = bool
  default     = false
}

variable "policy" {
  description = "The policy document as a JSON string"
  type        = string
  default     = null
}

################################################################################
# Vector Indexes
################################################################################

variable "indexes" {
  description = "A map of vector indexes to create in the vector bucket. Each key is an arbitrary index name used for resource naming."
  type = map(object({
    index_name      = string
    dimension       = number
    distance_metric = string
    data_type       = optional(string, "float32")
    tags            = optional(map(string), {})
    encryption_configuration = optional(object({
      sse_type    = string
      kms_key_arn = optional(string)
    }), null)
    metadata_configuration = optional(object({
      non_filterable_metadata_keys = list(string)
    }), null)
  }))
  default = {}
}
