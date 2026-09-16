output "file_systems" {
  description = "Map of file systems created and their attributes"
  value       = module.s3_bucket.file_systems
}

output "file_system_mount_targets" {
  description = "Map of file system mount targets created and their attributes"
  value       = module.s3_bucket.file_system_mount_targets
}

output "file_system_access_points" {
  description = "Map of file system access points created and their attributes"
  value       = module.s3_bucket.file_system_access_points
}

output "file_system_iam_roles" {
  description = "Map of IAM roles created for the file systems, with their ARN, name and unique ID"
  value       = module.s3_bucket.file_system_iam_roles
}

output "file_system_security_group_arn" {
  description = "ARN of the file system security group"
  value       = module.s3_bucket.file_system_security_group_arn
}

output "file_system_security_group_id" {
  description = "ID of the file system security group"
  value       = module.s3_bucket.file_system_security_group_id
}

################################################################################
# File System On A Bucket This Module Does Not Manage
################################################################################

output "external_file_system" {
  description = "The file system created on the bucket this module does not manage"
  value       = module.file_system.file_system
}

output "external_file_system_security_group_id" {
  description = "ID of the security group created for that file system's mount targets"
  value       = module.file_system.security_group_id
}
