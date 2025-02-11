output "bucket_id" {
  description = "The ID of the existing S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "The ARN of the existing S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}

output "policy" {
  description = "The applied bucket policy"
  value       = module.s3_bucket.s3_bucket_policy
}
