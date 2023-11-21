variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

variable "bucket" {
  description = "The name of the bucket to put the file in. Alternatively, an S3 access point ARN can be specified."
  type        = string
  default     = ""
}

variable "key" {
  description = "The name of the object once it is in the bucket."
  type        = string
  default     = ""
}

variable "file_source" {
  description = "The path to a file that will be read and uploaded as raw bytes for the object content."
  type        = string
  default     = null
}

variable "content" {
  description = "Literal string value to use as the object content, which will be uploaded as UTF-8-encoded text."
  type        = string
  default     = null
}

variable "content_base64" {
  description = "Base64-encoded data that will be decoded and uploaded as raw bytes for the object content. This allows safely uploading non-UTF8 binary data, but is recommended only for small content such as the result of the gzipbase64 function with small text strings. For larger objects, use source to stream the content from a disk file."
  type        = string
  default     = null
}

variable "acl" {
  description = "The canned ACL to apply. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, and bucket-owner-full-control. Defaults to private."
  type        = string
  default     = null
}

variable "cache_control" {
  description = "Specifies caching behavior along the request/reply chain."
  type        = string # map?
  default     = null
}

variable "content_disposition" {
  description = "Specifies presentational information for the object."
  type        = string # map?
  default     = null
}

variable "content_encoding" {
  description = "Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field."
  type        = string
  default     = null
}

variable "content_language" {
  description = "The language the content is in e.g. en-US or en-GB."
  type        = string
  default     = null
}

variable "content_type" {
  description = "A standard MIME type describing the format of the object data, e.g. application/octet-stream. All Valid MIME Types are valid for this input."
  type        = string
  default     = null
}

variable "website_redirect" {
  description = "Specifies a target URL for website redirect."
  type        = string
  default     = null
}

variable "storage_class" {
  description = "Specifies the desired Storage Class for the object. Can be either STANDARD, REDUCED_REDUNDANCY, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE, or STANDARD_IA. Defaults to STANDARD."
  type        = string
  default     = null
}

variable "etag" {
  description = "Used to trigger updates. This attribute is not compatible with KMS encryption, kms_key_id or server_side_encryption = \"aws:kms\"."
  type        = string
  default     = null
}

variable "server_side_encryption" {
  description = "Specifies server-side encryption of the object in S3. Valid values are \"AES256\" and \"aws:kms\"."
  type        = string
  default     = null
}

variable "kms_key_id" {
  description = "Amazon Resource Name (ARN) of the KMS Key to use for object encryption. If the S3 Bucket has server-side encryption enabled, that value will automatically be used. If referencing the aws_kms_key resource, use the arn attribute. If referencing the aws_kms_alias data source or resource, use the target_key_arn attribute. Terraform will only perform drift detection if a configuration value is provided."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = null
}

variable "metadata" {
  description = "A map of keys/values to provision metadata (will be automatically prefixed by x-amz-meta-, note that only lowercase label are currently supported by the AWS Go API)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to assign to the object."
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Allow the object to be deleted by removing any legal hold on any object version. Default is false. This value should be set to true only if the bucket has S3 object lock enabled."
  type        = bool
  default     = false
}

variable "object_lock_legal_hold_status" {
  description = "The legal hold status that you want to apply to the specified object. Valid values are ON and OFF."
  type        = string
  default     = null
}

variable "object_lock_mode" {
  description = "The object lock retention mode that you want to apply to this object. Valid values are GOVERNANCE and COMPLIANCE."
  type        = string
  default     = null
}

variable "object_lock_retain_until_date" {
  description = "The date and time, in RFC3339 format, when this object's object lock will expire."
  type        = string
  default     = null
}

variable "source_hash" {
  description = "Triggers updates like etag but useful to address etag encryption limitations. Set using filemd5(\"path/to/source\") (Terraform 0.11.12 or later). (The value is only stored in state and not saved by AWS.)"
  type        = string
  default     = null
}

variable "override_default_tags" {
  description = "Ignore provider default_tags. S3 objects support a maximum of 10 tags."
  type        = bool
  default     = false
}
