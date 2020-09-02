variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

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

variable "lambda_notifications" {
  description = "Map of S3 bucket notifications to Lambda function"
  type        = any # map(map(any)) is better, but Terraform 0.12.25 panics
  default     = {}
}

variable "sqs_notifications" {
  description = "Map of S3 bucket notifications to SQS queue"
  type        = any # map(map(any)) is better, but Terraform 0.12.25 panics
  default     = {}
}

variable "sns_notifications" {
  description = "Map of S3 bucket notifications to SNS topic"
  type        = any # map(map(any)) is better, but Terraform 0.12.25 panics
  default     = {}
}
