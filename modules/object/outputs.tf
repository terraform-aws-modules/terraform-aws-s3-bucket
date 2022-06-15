output "s3_object_id" {
  description = "The key of S3 object"
  value       = try(aws_s3_object.this[0].id, "")
}

output "s3_object_etag" {
  description = "The ETag generated for the object (an MD5 sum of the object content)."
  value       = try(aws_s3_object.this[0].etag, "")
}

output "s3_object_version_id" {
  description = "A unique version ID value for the object, if bucket versioning is enabled."
  value       = try(aws_s3_object.this[0].version_id, "")
}
