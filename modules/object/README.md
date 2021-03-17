# S3 bucket object

Creates S3 bucket objects with different configurations.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6 |
| aws | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_s3_bucket_object](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acl | The canned ACL to apply. Valid values are private, public-read, public-read-write, aws-exec-read, authenticated-read, bucket-owner-read, and bucket-owner-full-control. Defaults to private. | `string` | `null` | no |
| bucket | The name of the bucket to put the file in. Alternatively, an S3 access point ARN can be specified. | `string` | `""` | no |
| cache\_control | Specifies caching behavior along the request/reply chain. | `string` | `null` | no |
| content | Literal string value to use as the object content, which will be uploaded as UTF-8-encoded text. | `string` | `null` | no |
| content\_base64 | Base64-encoded data that will be decoded and uploaded as raw bytes for the object content. This allows safely uploading non-UTF8 binary data, but is recommended only for small content such as the result of the gzipbase64 function with small text strings. For larger objects, use source to stream the content from a disk file. | `string` | `null` | no |
| content\_disposition | Specifies presentational information for the object. | `string` | `null` | no |
| content\_encoding | Specifies what content encodings have been applied to the object and thus what decoding mechanisms must be applied to obtain the media-type referenced by the Content-Type header field. | `string` | `null` | no |
| content\_language | The language the content is in e.g. en-US or en-GB. | `string` | `null` | no |
| content\_type | A standard MIME type describing the format of the object data, e.g. application/octet-stream. All Valid MIME Types are valid for this input. | `string` | `null` | no |
| create | Whether to create this resource or not? | `bool` | `true` | no |
| etag | Used to trigger updates. This attribute is not compatible with KMS encryption, kms\_key\_id or server\_side\_encryption = "aws:kms". | `string` | `null` | no |
| file\_source | The path to a file that will be read and uploaded as raw bytes for the object content. | `string` | `null` | no |
| force\_destroy | Allow the object to be deleted by removing any legal hold on any object version. Default is false. This value should be set to true only if the bucket has S3 object lock enabled. | `bool` | `false` | no |
| key | The name of the object once it is in the bucket. | `string` | `""` | no |
| kms\_key\_id | Amazon Resource Name (ARN) of the KMS Key to use for object encryption. If the S3 Bucket has server-side encryption enabled, that value will automatically be used. If referencing the aws\_kms\_key resource, use the arn attribute. If referencing the aws\_kms\_alias data source or resource, use the target\_key\_arn attribute. Terraform will only perform drift detection if a configuration value is provided. | `string` | `null` | no |
| metadata | A map of keys/values to provision metadata (will be automatically prefixed by x-amz-meta-, note that only lowercase label are currently supported by the AWS Go API). | `map(string)` | `{}` | no |
| object\_lock\_legal\_hold\_status | The legal hold status that you want to apply to the specified object. Valid values are ON and OFF. | `string` | `null` | no |
| object\_lock\_mode | The object lock retention mode that you want to apply to this object. Valid values are GOVERNANCE and COMPLIANCE. | `string` | `null` | no |
| object\_lock\_retain\_until\_date | The date and time, in RFC3339 format, when this object's object lock will expire. | `string` | `null` | no |
| server\_side\_encryption | Specifies server-side encryption of the object in S3. Valid values are "AES256" and "aws:kms". | `string` | `null` | no |
| storage\_class | Specifies the desired Storage Class for the object. Can be either STANDARD, REDUCED\_REDUNDANCY, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, DEEP\_ARCHIVE, or STANDARD\_IA. Defaults to STANDARD. | `string` | `null` | no |
| tags | A map of tags to assign to the object. | `map(string)` | `{}` | no |
| website\_redirect | Specifies a target URL for website redirect. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_s3\_bucket\_object\_etag | The ETag generated for the object (an MD5 sum of the object content). |
| this\_s3\_bucket\_object\_id | The key of S3 object |
| this\_s3\_bucket\_object\_version\_id | A unique version ID value for the object, if bucket versioning is enabled. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
