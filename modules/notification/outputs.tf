output "s3_bucket_notification_id" {
  description = "ID of S3 bucket"
  value       = element(concat(aws_s3_bucket_notification.this.*.id, [""]), 0)
}
