# S3 object
output "this_s3_bucket_object_id" {
  description = "The key of S3 object"
  value       = module.object.this_s3_bucket_object_id
}

output "this_s3_bucket_object_etag" {
  description = "The ETag generated for the object (an MD5 sum of the object content)."
  value       = module.object.this_s3_bucket_object_etag
}

output "this_s3_bucket_object_version_id" {
  description = "A unique version ID value for the object, if bucket versioning is enabled."
  value       = module.object.this_s3_bucket_object_version_id
}

# S3 bucket
output "this_s3_bucket_id" {
  description = "The name of the bucket."
  value       = module.s3_bucket.this_s3_bucket_id
}

output "this_s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.s3_bucket.this_s3_bucket_arn
}
