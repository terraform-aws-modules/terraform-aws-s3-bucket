output "s3_bucket_notification_id" {
  description = "ID of S3 bucket"
  value       = try(aws_s3_bucket_notification.this[0].id, "")
}
