# S3 Table Bucket

Creates S3 Table Bucket and Tables with various configurations.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3tables_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table) | resource |
| [aws_s3tables_table_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_bucket) | resource |
| [aws_s3tables_table_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_bucket_policy) | resource |
| [aws_s3tables_table_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3tables_table_policy) | resource |
| [aws_iam_policy_document.table_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.table_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create s3 table resources | `bool` | `true` | no |
| <a name="input_create_table_bucket_policy"></a> [create\_table\_bucket\_policy](#input\_create\_table\_bucket\_policy) | Whether to create s3 table bucket policy | `bool` | `false` | no |
| <a name="input_encryption_configuration"></a> [encryption\_configuration](#input\_encryption\_configuration) | Map of encryption configurations | `any` | `null` | no |
| <a name="input_maintenance_configuration"></a> [maintenance\_configuration](#input\_maintenance\_configuration) | Map of table bucket maintenance configurations | `any` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the region set in the provider configuration | `string` | `null` | no |
| <a name="input_table_bucket_name"></a> [table\_bucket\_name](#input\_table\_bucket\_name) | Name of the table bucket. Must be between 3 and 63 characters in length. Can consist of lowercase letters, numbers, and hyphens, and must begin and end with a lowercase letter or number | `string` | `null` | no |
| <a name="input_table_bucket_override_policy_documents"></a> [table\_bucket\_override\_policy\_documents](#input\_table\_bucket\_override\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. In merging, statements with non-blank `sid`s will override statements with the same `sid` | `list(string)` | `[]` | no |
| <a name="input_table_bucket_policy"></a> [table\_bucket\_policy](#input\_table\_bucket\_policy) | Amazon Web Services resource-based policy document in JSON format | `string` | `null` | no |
| <a name="input_table_bucket_policy_statements"></a> [table\_bucket\_policy\_statements](#input\_table\_bucket\_policy\_statements) | A map of IAM policy [statements](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document#statement) for custom permission usage | `any` | `{}` | no |
| <a name="input_table_bucket_source_policy_documents"></a> [table\_bucket\_source\_policy\_documents](#input\_table\_bucket\_source\_policy\_documents) | List of IAM policy documents that are merged together into the exported document. Statements must have unique `sid`s | `list(string)` | `[]` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | Map of table configurations | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_table_arns"></a> [s3\_table\_arns](#output\_s3\_table\_arns) | The table ARNs. |
| <a name="output_s3_table_bucket_arn"></a> [s3\_table\_bucket\_arn](#output\_s3\_table\_bucket\_arn) | ARN of the table bucket. |
| <a name="output_s3_table_bucket_created_at"></a> [s3\_table\_bucket\_created\_at](#output\_s3\_table\_bucket\_created\_at) | Date and time when the bucket was created. |
| <a name="output_s3_table_bucket_owner_account_id"></a> [s3\_table\_bucket\_owner\_account\_id](#output\_s3\_table\_bucket\_owner\_account\_id) | Account ID of the account that owns the table bucket. |
| <a name="output_s3_table_created_at"></a> [s3\_table\_created\_at](#output\_s3\_table\_created\_at) | Dates and times when the tables were created. |
| <a name="output_s3_table_created_by"></a> [s3\_table\_created\_by](#output\_s3\_table\_created\_by) | Account IDs of the accounts that created the tables |
| <a name="output_s3_table_metadata_locations"></a> [s3\_table\_metadata\_locations](#output\_s3\_table\_metadata\_locations) | Locations of table metadata. |
| <a name="output_s3_table_modified_at"></a> [s3\_table\_modified\_at](#output\_s3\_table\_modified\_at) | Dates and times when the tables was last modified. |
| <a name="output_s3_table_modified_by"></a> [s3\_table\_modified\_by](#output\_s3\_table\_modified\_by) | Account IDs of the accounts that last modified the tables. |
| <a name="output_s3_table_owner_account_ids"></a> [s3\_table\_owner\_account\_ids](#output\_s3\_table\_owner\_account\_ids) | Account IDs of the accounts that owns the tables. |
| <a name="output_s3_table_types"></a> [s3\_table\_types](#output\_s3\_table\_types) | Types of the tables. One of customer or aws. |
| <a name="output_s3_table_version_tokens"></a> [s3\_table\_version\_tokens](#output\_s3\_table\_version\_tokens) | Identifiers for the current version of table data. |
| <a name="output_s3_table_warehouse_locations"></a> [s3\_table\_warehouse\_locations](#output\_s3\_table\_warehouse\_locations) | S3 URIs pointing to the S3 Bucket that contains the table data. |
<!-- END_TF_DOCS -->
