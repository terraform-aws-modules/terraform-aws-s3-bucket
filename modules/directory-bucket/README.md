# S3 directory bucket

Creates S3 directory bucket and configurations.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.83 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.83 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_directory_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_directory_bucket) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zone_id"></a> [availability\_zone\_id](#input\_availability\_zone\_id) | Availability Zone ID or Local Zone ID | `string` | `null` | no |
| <a name="input_bucket_name_prefix"></a> [bucket\_name\_prefix](#input\_bucket\_name\_prefix) | Bucket name prefix | `string` | `null` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create directory bucket resources | `bool` | `true` | no |
| <a name="input_create_bucket_policy"></a> [create\_bucket\_policy](#input\_create\_bucket\_policy) | Whether to create a directory bucket policy. | `bool` | `false` | no |
| <a name="input_data_redundancy"></a> [data\_redundancy](#input\_data\_redundancy) | Data redundancy. Valid values: `SingleAvailabilityZone` | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Boolean that indicates all objects should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error. These objects are not recoverable | `bool` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of maps containing configuration of object lifecycle management. | `any` | `{}` | no |
| <a name="input_location_type"></a> [location\_type](#input\_location\_type) | Location type. Valid values: `AvailabilityZone` or `LocalZone` | `string` | `null` | no |
| <a name="input_override_policy_documents"></a> [override\_policy\_documents](#input\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_policy_statements"></a> [policy\_statements](#input\_policy\_statements) | A map of IAM policy statements for custom permission usage | `any` | `{}` | no |
| <a name="input_server_side_encryption_configuration"></a> [server\_side\_encryption\_configuration](#input\_server\_side\_encryption\_configuration) | Map containing server-side encryption configuration. | `any` | `{}` | no |
| <a name="input_source_policy_documents"></a> [source\_policy\_documents](#input\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_type"></a> [type](#input\_type) | Bucket type. Valid values: `Directory` | `string` | `"Directory"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_directory_bucket_arn"></a> [directory\_bucket\_arn](#output\_directory\_bucket\_arn) | ARN of the directory bucket. |
| <a name="output_directory_bucket_name"></a> [directory\_bucket\_name](#output\_directory\_bucket\_name) | Name of the directory bucket. |
<!-- END_TF_DOCS -->
