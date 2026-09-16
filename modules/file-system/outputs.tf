################################################################################
# File System
################################################################################

output "file_system" {
  description = "The file system created and its attributes"
  value       = try(aws_s3files_file_system.this[0], null)
}

################################################################################
# IAM Role
################################################################################

output "iam_role_arn" {
  description = "ARN of the IAM role created"
  value       = try(aws_iam_role.this[0].arn, null)
}

output "iam_role_name" {
  description = "Name of the IAM role created"
  value       = try(aws_iam_role.this[0].name, null)
}

output "iam_role_unique_id" {
  description = "Unique ID of the IAM role created"
  value       = try(aws_iam_role.this[0].unique_id, null)
}

################################################################################
# Mount Target(s)
################################################################################

output "mount_targets" {
  description = "Map of mount targets created and their attributes"
  value       = aws_s3files_mount_target.this
}

################################################################################
# Security Group
################################################################################

output "security_group_arn" {
  description = "ARN of the security group created"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group created"
  value       = try(aws_security_group.this[0].id, null)
}

################################################################################
# Access Point(s)
################################################################################

output "access_points" {
  description = "Map of access points created and their attributes"
  value       = aws_s3files_access_point.this
}
