output "s3_files_file_system_id" {
  description = "Identifier of the S3 Files file system"
  value       = try(aws_s3files_file_system.this[0].id, null)
}

output "s3_files_file_system_arn" {
  description = "ARN of the S3 Files file system"
  value       = try(aws_s3files_file_system.this[0].arn, null)
}

output "s3_files_mount_target_network_interface_ids" {
  description = "List of mount target network interface IDs"
  value       = [for mt in aws_s3files_mount_target.this : mt.network_interface_id]
}

output "s3_files_access_points" {
  description = "Map of S3 Files access points, keyed by the user-defined map key, with id, arn, and name attributes"
  value       = { for k, ap in aws_s3files_access_point.this : k => { id = ap.id, arn = ap.arn, name = ap.name } }
}
