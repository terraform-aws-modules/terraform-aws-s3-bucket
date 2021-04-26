output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = element(concat(aws_s3_bucket_policy.this.*.id, aws_s3_bucket.this.*.id, [""]), 0)
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = element(concat(aws_s3_bucket.this.*.arn, [""]), 0)
}

output "s3_bucket_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = element(concat(aws_s3_bucket.this.*.bucket_domain_name, [""]), 0)
}

output "s3_bucket_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL."
  value       = element(concat(aws_s3_bucket.this.*.bucket_regional_domain_name, [""]), 0)
}

output "s3_bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = element(concat(aws_s3_bucket.this.*.hosted_zone_id, [""]), 0)
}

output "s3_bucket_region" {
  description = "The AWS region this bucket resides in."
  value       = element(concat(aws_s3_bucket.this.*.region, [""]), 0)
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = element(concat(aws_s3_bucket.this.*.website_endpoint, [""]), 0)
}

output "s3_bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. "
  value       = element(concat(aws_s3_bucket.this.*.website_domain, [""]), 0)
}
