output "directory_bucket_name" {
  description = "Name of the directory bucket."
  value       = try(aws_s3_directory_bucket.this[0].bucket, null)
}

output "directory_bucket_arn" {
  description = "ARN of the directory bucket."
  value       = try(aws_s3_directory_bucket.this[0].arn, null)
}
