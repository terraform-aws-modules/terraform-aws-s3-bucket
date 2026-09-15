variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

################################################################################
# Bucket Notification
################################################################################

variable "bucket" {
  description = "Name of S3 bucket to use"
  type        = string
  default     = ""
}

variable "bucket_arn" {
  description = "ARN of S3 bucket to use in policies"
  type        = string
  default     = null
}

variable "eventbridge" {
  description = "Whether to enable Amazon EventBridge notifications"
  type        = bool
  default     = null
}

################################################################################
# Lambda
################################################################################

variable "lambda_notifications" {
  description = "Map of S3 bucket notifications to Lambda function"
  type = map(object({
    id             = optional(string)
    events         = list(string)
    filter_prefix  = optional(string)
    filter_suffix  = optional(string)
    function_arn   = string
    function_name  = optional(string)
    qualifier      = optional(string)
    source_account = optional(string)
  }))
  default = {}
}

variable "create_lambda_permission" {
  description = "Whether to create Lambda permissions or not?"
  type        = bool
  default     = true
}

################################################################################
# SQS
################################################################################

variable "sqs_notifications" {
  description = "Map of S3 bucket notifications to SQS queue"
  type = map(object({
    id            = optional(string)
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
    queue_arn     = string
    queue_id      = optional(string)
  }))
  default = {}
}

variable "create_sqs_policy" {
  description = "Whether to create a policy for SQS permissions or not?"
  type        = bool
  default     = true
}

################################################################################
# SNS
################################################################################

variable "sns_notifications" {
  description = "Map of S3 bucket notifications to SNS topic"
  type = map(object({
    id            = optional(string)
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
    topic_arn     = string
  }))
  default = {}
}

variable "create_sns_policy" {
  description = "Whether to create a policy for SNS permissions or not?"
  type        = bool
  default     = true
}
