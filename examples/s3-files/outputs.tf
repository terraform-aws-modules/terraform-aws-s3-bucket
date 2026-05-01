output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket."
  value       = module.s3_bucket.s3_bucket_arn
}

output "s3_bucket_versioning_status" {
  description = "Versioning status of the example S3 bucket."
  value       = module.s3_bucket.aws_s3_bucket_versioning_status
}

output "s3_files_file_system_id" {
  description = "Identifier of the S3 Files file system."
  value       = module.s3_files.s3_files_file_system_id
}

output "s3_files_file_system_arn" {
  description = "ARN of the S3 Files file system."
  value       = module.s3_files.s3_files_file_system_arn
}

output "s3_files_mount_target_network_interface_ids" {
  description = "List of mount target network interface IDs."
  value       = module.s3_files.s3_files_mount_target_network_interface_ids
}
