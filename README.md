# AWS S3 bucket Terraform module

Terraform module which creates S3 bucket on AWS with all (or almost all) features provided by Terraform AWS provider.

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

These features of S3 bucket configurations are supported:

- static web-site hosting
- access logging
- versioning
- CORS
- lifecycle rules
- server-side encryption
- object locking
- Cross-Region Replication (CRR)
- ELB log delivery bucket policy
- ALB/NLB log delivery bucket policy
- WAF log delivery bucket policy
- Account-level Public Access Block
- S3 Directory Bucket
- S3 Table Bucket
- S3 Vectors

## Usage

### Private bucket with versioning enabled

```hcl
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}
```

### Bucket with ELB access log delivery policy attached

```hcl
module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-for-logs"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true
}
```

### Bucket with ALB/NLB access log delivery policy attached

```hcl
module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-for-logs"

  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_lb_log_delivery_policy = true # Required for ALB/NLB logs
}
```

### Bucket with WAF log delivery policy attached

```hcl
module "s3_bucket_for_waf_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-for-waf-logs"

  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_waf_log_delivery_policy = true  # Required for WAF logs
}
```

### Bucket with a custom policy attached

When you need to attach a custom policy to the bucket, use the `policy` argument. The placeholders `_S3_BUCKET_ID_`, `_S3_BUCKET_ARN_` and `_AWS_ACCOUNT_ID_` are replaced with the real values when the policy is attached, which is what makes a policy work against a bucket whose name is generated from `bucket_prefix`.

```hcl
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix = "my-s3-bucket-"

  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyInsecureTransport"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource  = ["_S3_BUCKET_ARN_", "_S3_BUCKET_ARN_/*"]
      Condition = {
        Bool = { "aws:SecureTransport" = "false" }
      }
    }]
  })
}
```

## Conditional creation

Sometimes you need to have a way to create S3 resources conditionally but Terraform does not allow to use `count` inside `module` block, so the solution is to specify argument `create_bucket`.

```hcl
# This S3 bucket will not be created
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  create_bucket = false
  # ... omitted
}
```

## Module wrappers

Users of this Terraform module can create multiple similar resources by using [`for_each` meta-argument within `module` block](https://www.terraform.io/language/meta-arguments/for_each) which became available in Terraform 0.13.

Users of Terragrunt can achieve similar results by using modules provided in the [wrappers](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/wrappers) directory, if they prefer to reduce amount of configuration files.

## Examples

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/complete) - Complete S3 bucket with most of supported features enabled
- [Cross-Region Replication](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-replication) - S3 bucket with Cross-Region Replication (CRR) enabled
- [S3 Notifications](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/notification) - S3 bucket notifications to Lambda functions, SQS queues, and SNS topics.
- [S3 Object](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/object) - Manage S3 bucket objects.
- [S3 Inventory and Analytics](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/inventory-and-analytics) - S3 bucket Inventory and Analytics configurations.
- [S3 ACLs](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/acl) - S3 bucket ACLs, for the buckets that still require them.
- [S3 Bucket Policies](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/bucket-policies) - Attach the bundled log delivery and transport policies.
- [S3 Account-level Public Access Block](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/account-public-access) - Manage S3 account-level Public Access Block.
- [S3 Directory Bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/directory-bucket) - S3 Directory Bucket configuration.
- [S3 Table Bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/table-bucket) - S3 Table Bucket configuration.
- [S3 Vectors](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/vectors) - S3 Vectors vector bucket with indexes configuration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.42 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_accelerate_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_accelerate_configuration) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_analytics_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_analytics_configuration) | resource |
| [aws_s3_bucket_cors_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_intelligent_tiering_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_intelligent_tiering_configuration) | resource |
| [aws_s3_bucket_inventory.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_inventory) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_metadata_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_metadata_configuration) | resource |
| [aws_s3_bucket_metric.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_metric) | resource |
| [aws_s3_bucket_object_lock_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_request_payment_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_request_payment_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |
| [aws_s3_directory_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_directory_bucket) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_iam_policy_document.access_log_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_log_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.combined](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_incorrect_encryption_headers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_incorrect_kms_key_sse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_insecure_transport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_ssec_encrypted_object_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.deny_unencrypted_object_uploads](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.elb_log_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inventory_and_analytics_destination_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lb_log_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.require_latest_tls](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.waf_log_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_acceleration_status"></a> [acceleration\_status](#input\_acceleration\_status) | Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended | `string` | `null` | no |
| <a name="input_access_log_delivery_policy_source_accounts"></a> [access\_log\_delivery\_policy\_source\_accounts](#input\_access\_log\_delivery\_policy\_source\_accounts) | List of AWS Account IDs should be allowed to deliver access logs to this bucket | `list(string)` | `[]` | no |
| <a name="input_access_log_delivery_policy_source_buckets"></a> [access\_log\_delivery\_policy\_source\_buckets](#input\_access\_log\_delivery\_policy\_source\_buckets) | List of S3 bucket ARNs which should be allowed to deliver access logs to this bucket | `list(string)` | `[]` | no |
| <a name="input_access_log_delivery_policy_source_organizations"></a> [access\_log\_delivery\_policy\_source\_organizations](#input\_access\_log\_delivery\_policy\_source\_organizations) | List of AWS Organization IDs should be allowed to deliver access logs to this bucket | `list(string)` | `[]` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | The canned ACL to apply. Conflicts with `grant` | `string` | `null` | no |
| <a name="input_allowed_kms_key_arn"></a> [allowed\_kms\_key\_arn](#input\_allowed\_kms\_key\_arn) | The ARN of KMS key which should be allowed in PutObject | `string` | `null` | no |
| <a name="input_analytics_configuration"></a> [analytics\_configuration](#input\_analytics\_configuration) | Analytics configurations for the bucket, keyed by configuration name | <pre>map(object({<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>      tags   = optional(map(string))<br/>    }))<br/>    storage_class_analysis = optional(object({<br/>      output_schema_version  = optional(string)<br/>      destination_bucket_arn = optional(string)<br/>      destination_account_id = optional(string)<br/>      export_format          = optional(string)<br/>      export_prefix          = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_analytics_self_source_destination"></a> [analytics\_self\_source\_destination](#input\_analytics\_self\_source\_destination) | Whether or not the analytics source bucket is also the destination bucket | `bool` | `false` | no |
| <a name="input_analytics_source_account_id"></a> [analytics\_source\_account\_id](#input\_analytics\_source\_account\_id) | The analytics source account id | `string` | `null` | no |
| <a name="input_analytics_source_bucket_arn"></a> [analytics\_source\_bucket\_arn](#input\_analytics\_source\_bucket\_arn) | The analytics source bucket ARN | `string` | `null` | no |
| <a name="input_attach_access_log_delivery_policy"></a> [attach\_access\_log\_delivery\_policy](#input\_attach\_access\_log\_delivery\_policy) | Controls if S3 bucket should have S3 access log delivery policy attached | `bool` | `false` | no |
| <a name="input_attach_analytics_destination_policy"></a> [attach\_analytics\_destination\_policy](#input\_attach\_analytics\_destination\_policy) | Controls if S3 bucket should have bucket analytics destination policy attached | `bool` | `false` | no |
| <a name="input_attach_cloudtrail_log_delivery_policy"></a> [attach\_cloudtrail\_log\_delivery\_policy](#input\_attach\_cloudtrail\_log\_delivery\_policy) | Controls if S3 bucket should have CloudTrail log delivery policy attached | `bool` | `false` | no |
| <a name="input_attach_deny_incorrect_encryption_headers"></a> [attach\_deny\_incorrect\_encryption\_headers](#input\_attach\_deny\_incorrect\_encryption\_headers) | Controls if S3 bucket should deny incorrect encryption headers policy attached | `bool` | `false` | no |
| <a name="input_attach_deny_incorrect_kms_key_sse"></a> [attach\_deny\_incorrect\_kms\_key\_sse](#input\_attach\_deny\_incorrect\_kms\_key\_sse) | Controls if S3 bucket policy should deny usage of incorrect KMS key SSE | `bool` | `false` | no |
| <a name="input_attach_deny_insecure_transport_policy"></a> [attach\_deny\_insecure\_transport\_policy](#input\_attach\_deny\_insecure\_transport\_policy) | Controls if S3 bucket should have deny non-SSL transport policy attached | `bool` | `false` | no |
| <a name="input_attach_deny_ssec_encrypted_object_uploads"></a> [attach\_deny\_ssec\_encrypted\_object\_uploads](#input\_attach\_deny\_ssec\_encrypted\_object\_uploads) | Controls if S3 bucket should deny SSEC encrypted object uploads | `bool` | `false` | no |
| <a name="input_attach_deny_unencrypted_object_uploads"></a> [attach\_deny\_unencrypted\_object\_uploads](#input\_attach\_deny\_unencrypted\_object\_uploads) | Controls if S3 bucket should deny unencrypted object uploads policy attached | `bool` | `false` | no |
| <a name="input_attach_elb_log_delivery_policy"></a> [attach\_elb\_log\_delivery\_policy](#input\_attach\_elb\_log\_delivery\_policy) | Controls if S3 bucket should have ELB log delivery policy attached | `bool` | `false` | no |
| <a name="input_attach_inventory_destination_policy"></a> [attach\_inventory\_destination\_policy](#input\_attach\_inventory\_destination\_policy) | Controls if S3 bucket should have bucket inventory destination policy attached | `bool` | `false` | no |
| <a name="input_attach_lb_log_delivery_policy"></a> [attach\_lb\_log\_delivery\_policy](#input\_attach\_lb\_log\_delivery\_policy) | Controls if S3 bucket should have ALB/NLB log delivery policy attached | `bool` | `false` | no |
| <a name="input_attach_policy"></a> [attach\_policy](#input\_attach\_policy) | Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy) | `bool` | `false` | no |
| <a name="input_attach_public_policy"></a> [attach\_public\_policy](#input\_attach\_public\_policy) | Controls if the S3 Bucket Public Access Block is created (set to `false` to allow upstream to apply defaults to the bucket) | `bool` | `true` | no |
| <a name="input_attach_require_latest_tls_policy"></a> [attach\_require\_latest\_tls\_policy](#input\_attach\_require\_latest\_tls\_policy) | Controls if S3 bucket should require the latest version of TLS | `bool` | `false` | no |
| <a name="input_attach_waf_log_delivery_policy"></a> [attach\_waf\_log\_delivery\_policy](#input\_attach\_waf\_log\_delivery\_policy) | Controls if S3 bucket should have WAF log delivery policy attached | `bool` | `false` | no |
| <a name="input_availability_zone_id"></a> [availability\_zone\_id](#input\_availability\_zone\_id) | Availability Zone ID or Local Zone ID | `string` | `null` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Whether Amazon S3 should block public ACLs for this bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Whether Amazon S3 should block public bucket policies for this bucket | `bool` | `true` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | The name of the bucket. If omitted, Terraform will assign a random, unique name | `string` | `null` | no |
| <a name="input_bucket_namespace"></a> [bucket\_namespace](#input\_bucket\_namespace) | Namespace for the bucket. Determines bucket naming scope. Valid values: `account-regional`, `global`. Defaults to `global` (AWS) | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket | `string` | `null` | no |
| <a name="input_control_object_ownership"></a> [control\_object\_ownership](#input\_control\_object\_ownership) | Whether to manage S3 Bucket Ownership Controls on this bucket | `bool` | `false` | no |
| <a name="input_cors_rule"></a> [cors\_rule](#input\_cors\_rule) | Rules for Cross-Origin Resource Sharing on the bucket | <pre>list(object({<br/>    id              = optional(string)<br/>    allowed_methods = list(string)<br/>    allowed_origins = list(string)<br/>    allowed_headers = optional(list(string))<br/>    expose_headers  = optional(list(string))<br/>    max_age_seconds = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Controls if S3 bucket should be created | `bool` | `true` | no |
| <a name="input_create_metadata_configuration"></a> [create\_metadata\_configuration](#input\_create\_metadata\_configuration) | Whether to create metadata configuration resource | `bool` | `false` | no |
| <a name="input_data_redundancy"></a> [data\_redundancy](#input\_data\_redundancy) | Data redundancy. Valid values: `SingleAvailabilityZone` | `string` | `null` | no |
| <a name="input_expected_bucket_owner"></a> [expected\_bucket\_owner](#input\_expected\_bucket\_owner) | The account ID of the expected bucket owner | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable | `bool` | `false` | no |
| <a name="input_grant"></a> [grant](#input\_grant) | ACL policy grants for the bucket. Conflicts with `acl` | <pre>list(object({<br/>    id         = optional(string)<br/>    type       = string<br/>    permission = string<br/>    uri        = optional(string)<br/>    email      = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Whether Amazon S3 should ignore public ACLs for this bucket | `bool` | `true` | no |
| <a name="input_intelligent_tiering"></a> [intelligent\_tiering](#input\_intelligent\_tiering) | Intelligent tiering configurations for the bucket, keyed by configuration name | <pre>map(object({<br/>    status = optional(string)<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>      tags   = optional(map(string))<br/>    }))<br/>    tiering = map(object({<br/>      days = number<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_inventory_configuration"></a> [inventory\_configuration](#input\_inventory\_configuration) | Inventory configurations for the bucket, keyed by configuration name | <pre>map(object({<br/>    bucket                   = optional(string)<br/>    included_object_versions = string<br/>    enabled                  = optional(bool, true)<br/>    optional_fields          = optional(list(string))<br/>    frequency                = string<br/>    destination = object({<br/>      bucket_arn = optional(string)<br/>      format     = optional(string)<br/>      account_id = optional(string)<br/>      prefix     = optional(string)<br/>      encryption = optional(object({<br/>        encryption_type = string<br/>        kms_key_id      = optional(string)<br/>      }))<br/>    })<br/>    filter = optional(object({<br/>      prefix = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_inventory_self_source_destination"></a> [inventory\_self\_source\_destination](#input\_inventory\_self\_source\_destination) | Whether or not the inventory source bucket is also the destination bucket | `bool` | `false` | no |
| <a name="input_inventory_source_account_id"></a> [inventory\_source\_account\_id](#input\_inventory\_source\_account\_id) | The inventory source account id | `string` | `null` | no |
| <a name="input_inventory_source_bucket_arn"></a> [inventory\_source\_bucket\_arn](#input\_inventory\_source\_bucket\_arn) | The inventory source bucket ARN | `string` | `null` | no |
| <a name="input_is_directory_bucket"></a> [is\_directory\_bucket](#input\_is\_directory\_bucket) | If the s3 bucket created is a directory bucket | `bool` | `false` | no |
| <a name="input_lb_log_delivery_policy_source_organizations"></a> [lb\_log\_delivery\_policy\_source\_organizations](#input\_lb\_log\_delivery\_policy\_source\_organizations) | List of AWS Organization IDs should be allowed to deliver ALB/NLB logs to this bucket | `list(string)` | `[]` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | Object lifecycle management rules for the bucket | <pre>list(object({<br/>    id      = optional(string)<br/>    prefix  = optional(string)<br/>    enabled = optional(bool)<br/>    status  = optional(string)<br/><br/>    abort_incomplete_multipart_upload_days = optional(number)<br/><br/>    expiration = optional(object({<br/>      date                         = optional(string)<br/>      days                         = optional(number)<br/>      expired_object_delete_marker = optional(bool)<br/>    }))<br/>    filter = optional(object({<br/>      object_size_greater_than = optional(number)<br/>      object_size_less_than    = optional(number)<br/>      prefix                   = optional(string)<br/>      tags                     = optional(map(string))<br/>      tag                      = optional(map(string))<br/>    }))<br/>    noncurrent_version_expiration = optional(object({<br/>      newer_noncurrent_versions = optional(number)<br/>      days                      = optional(number)<br/>      noncurrent_days           = optional(number)<br/>    }))<br/>    noncurrent_version_transition = optional(list(object({<br/>      newer_noncurrent_versions = optional(number)<br/>      days                      = optional(number)<br/>      noncurrent_days           = optional(number)<br/>      storage_class             = string<br/>    })), [])<br/>    transition = optional(list(object({<br/>      date          = optional(string)<br/>      days          = optional(number)<br/>      storage_class = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_location_type"></a> [location\_type](#input\_location\_type) | Location type. Valid values: `AvailabilityZone` or `LocalZone` | `string` | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Access log delivery configuration for the bucket | <pre>object({<br/>    target_bucket = string<br/>    target_prefix = optional(string)<br/>    target_object_key_format = optional(object({<br/>      partitioned_prefix = optional(object({<br/>        partition_date_source = optional(string)<br/>      }))<br/>      simple_prefix = optional(object({}))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_metadata_encryption_configuration"></a> [metadata\_encryption\_configuration](#input\_metadata\_encryption\_configuration) | Encryption configuration for the metadata inventory table | <pre>object({<br/>    kms_key_arn   = optional(string)<br/>    sse_algorithm = string<br/>  })</pre> | `null` | no |
| <a name="input_metadata_inventory_table_configuration_state"></a> [metadata\_inventory\_table\_configuration\_state](#input\_metadata\_inventory\_table\_configuration\_state) | Configuration state of the inventory table, indicating whether the inventory table is enabled or disabled. Valid values: `ENABLED`, `DISABLED` | `string` | `null` | no |
| <a name="input_metadata_journal_table_record_expiration"></a> [metadata\_journal\_table\_record\_expiration](#input\_metadata\_journal\_table\_record\_expiration) | Whether journal table record expiration is enabled or disabled. Valid values: `ENABLED`, `DISABLED` | `string` | `null` | no |
| <a name="input_metadata_journal_table_record_expiration_days"></a> [metadata\_journal\_table\_record\_expiration\_days](#input\_metadata\_journal\_table\_record\_expiration\_days) | Number of days to retain journal table records | `number` | `null` | no |
| <a name="input_metric_configuration"></a> [metric\_configuration](#input\_metric\_configuration) | Metric configurations for the bucket | <pre>list(object({<br/>    name = string<br/>    filter = optional(object({<br/>      prefix       = optional(string)<br/>      tags         = optional(map(string))<br/>      access_point = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | Object lock configuration for the bucket | <pre>object({<br/>    token = optional(string)<br/>    rule = optional(object({<br/>      default_retention = object({<br/>        mode  = string<br/>        days  = optional(number)<br/>        years = optional(number)<br/>      })<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_object_lock_enabled"></a> [object\_lock\_enabled](#input\_object\_lock\_enabled) | Whether S3 bucket should have an Object Lock configuration enabled | `bool` | `false` | no |
| <a name="input_object_ownership"></a> [object\_ownership](#input\_object\_ownership) | Object ownership. Valid values: `BucketOwnerEnforced`, `BucketOwnerPreferred` or `ObjectWriter`. `BucketOwnerEnforced`: ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. `BucketOwnerPreferred`: Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the `bucket-owner-full-control` canned ACL. `ObjectWriter`: The uploading account will own the object if the object is uploaded with the `bucket-owner-full-control` canned ACL | `string` | `"BucketOwnerEnforced"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Bucket owner's display name and ID. Conflicts with `acl` | `map(string)` | `{}` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide | `string` | `null` | no |
| <a name="input_putin_khuylo"></a> [putin\_khuylo](#input\_putin\_khuylo) | Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo! | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | no |
| <a name="input_replication_configuration"></a> [replication\_configuration](#input\_replication\_configuration) | Cross-region replication configuration for the bucket | <pre>object({<br/>    role = optional(string)<br/><br/>    # `rules` is the original name, `rule` was added to match the provider block. Set either<br/>    rule = optional(list(object({<br/>      id       = optional(string)<br/>      priority = optional(number)<br/>      status   = optional(string)<br/>      prefix   = optional(string)<br/><br/>      # Both spellings are accepted; the newer one matches the provider block name<br/>      delete_marker_replication          = optional(string)<br/>      delete_marker_replication_status   = optional(string)<br/>      existing_object_replication        = optional(string)<br/>      existing_object_replication_status = optional(string)<br/><br/>      filter = optional(object({<br/>        prefix = optional(string)<br/>        tags   = optional(map(string))<br/>        tag    = optional(map(string))<br/>      }))<br/>      source_selection_criteria = optional(object({<br/>        replica_modifications = optional(object({<br/>          enabled = optional(string)<br/>          status  = optional(string)<br/>        }))<br/>        sse_kms_encrypted_objects = optional(object({<br/>          enabled = optional(string)<br/>          status  = optional(string)<br/>        }))<br/>      }))<br/>      destination = object({<br/>        bucket        = string<br/>        storage_class = optional(string)<br/>        account       = optional(string)<br/>        account_id    = optional(string)<br/><br/>        replica_kms_key_id = optional(string)<br/>        encryption_configuration = optional(object({<br/>          replica_kms_key_id = optional(string)<br/>        }))<br/>        access_control_translation = optional(object({<br/>          owner = string<br/>        }))<br/>        replication_time = optional(object({<br/>          status  = optional(string)<br/>          minutes = optional(number)<br/>        }))<br/>        metrics = optional(object({<br/>          status  = optional(string)<br/>          minutes = optional(number)<br/>        }))<br/>      })<br/>    })))<br/>    rules = optional(list(object({<br/>      id       = optional(string)<br/>      priority = optional(number)<br/>      status   = optional(string)<br/>      prefix   = optional(string)<br/><br/>      # Both spellings are accepted; the newer one matches the provider block name<br/>      delete_marker_replication          = optional(string)<br/>      delete_marker_replication_status   = optional(string)<br/>      existing_object_replication        = optional(string)<br/>      existing_object_replication_status = optional(string)<br/><br/>      filter = optional(object({<br/>        prefix = optional(string)<br/>        tags   = optional(map(string))<br/>        tag    = optional(map(string))<br/>      }))<br/>      source_selection_criteria = optional(object({<br/>        replica_modifications = optional(object({<br/>          enabled = optional(string)<br/>          status  = optional(string)<br/>        }))<br/>        sse_kms_encrypted_objects = optional(object({<br/>          enabled = optional(string)<br/>          status  = optional(string)<br/>        }))<br/>      }))<br/>      destination = object({<br/>        bucket        = string<br/>        storage_class = optional(string)<br/>        account       = optional(string)<br/>        account_id    = optional(string)<br/><br/>        replica_kms_key_id = optional(string)<br/>        encryption_configuration = optional(object({<br/>          replica_kms_key_id = optional(string)<br/>        }))<br/>        access_control_translation = optional(object({<br/>          owner = string<br/>        }))<br/>        replication_time = optional(object({<br/>          status  = optional(string)<br/>          minutes = optional(number)<br/>        }))<br/>        metrics = optional(object({<br/>          status  = optional(string)<br/>          minutes = optional(number)<br/>        }))<br/>      })<br/>    })))<br/>  })</pre> | `{}` | no |
| <a name="input_request_payer"></a> [request\_payer](#input\_request\_payer) | Specifies who should bear the cost of Amazon S3 data transfer. Can be either `BucketOwner` or `Requester`. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information | `string` | `null` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Whether Amazon S3 should restrict public bucket policies for this bucket | `bool` | `true` | no |
| <a name="input_server_side_encryption_configuration"></a> [server\_side\_encryption\_configuration](#input\_server\_side\_encryption\_configuration) | Server-side encryption configuration for the bucket | <pre>object({<br/>    # AWS permits a single rule per bucket, and every example passes one object<br/>    rule = optional(object({<br/>      bucket_key_enabled       = optional(bool)<br/>      blocked_encryption_types = optional(list(string))<br/>      apply_server_side_encryption_by_default = optional(object({<br/>        sse_algorithm     = string<br/>        kms_master_key_id = optional(string)<br/>      }))<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_skip_destroy_public_access_block"></a> [skip\_destroy\_public\_access\_block](#input\_skip\_destroy\_public\_access\_block) | Whether to skip destroying the S3 Bucket Public Access Block configuration when destroying the bucket. Only used if `public_access_block` is set to true | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the bucket | `map(string)` | `{}` | no |
| <a name="input_transition_default_minimum_object_size"></a> [transition\_default\_minimum\_object\_size](#input\_transition\_default\_minimum\_object\_size) | The default minimum object size behavior applied to the lifecycle configuration. Valid values: `all_storage_classes_128K` (default) or `varies_by_storage_class` | `string` | `null` | no |
| <a name="input_type"></a> [type](#input\_type) | Bucket type. Valid values: `Directory` | `string` | `"Directory"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Versioning configuration for the bucket | `map(string)` | `{}` | no |
| <a name="input_website"></a> [website](#input\_website) | Static website hosting or redirect configuration for the bucket | <pre>object({<br/>    index_document = optional(string)<br/>    error_document = optional(string)<br/>    redirect_all_requests_to = optional(object({<br/>      host_name = string<br/>      protocol  = optional(string)<br/>    }))<br/>    routing_rules = optional(list(object({<br/>      condition = optional(object({<br/>        http_error_code_returned_equals = optional(string)<br/>        key_prefix_equals               = optional(string)<br/>      }))<br/>      redirect = optional(object({<br/>        host_name               = optional(string)<br/>        http_redirect_code      = optional(string)<br/>        protocol                = optional(string)<br/>        replace_key_prefix_with = optional(string)<br/>        replace_key_with        = optional(string)<br/>      }))<br/>    })))<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_aws_s3_bucket_versioning_status"></a> [aws\_s3\_bucket\_versioning\_status](#output\_aws\_s3\_bucket\_versioning\_status) | The versioning status of the bucket. Will be 'Enabled', 'Suspended', or 'Disabled' |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname |
| <a name="output_s3_bucket_bucket_domain_name"></a> [s3\_bucket\_bucket\_domain\_name](#output\_s3\_bucket\_bucket\_domain\_name) | The bucket domain name. Will be of format bucketname.s3.amazonaws.com |
| <a name="output_s3_bucket_bucket_namespace"></a> [s3\_bucket\_bucket\_namespace](#output\_s3\_bucket\_bucket\_namespace) | The namespace of the bucket |
| <a name="output_s3_bucket_bucket_regional_domain_name"></a> [s3\_bucket\_bucket\_regional\_domain\_name](#output\_s3\_bucket\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL |
| <a name="output_s3_bucket_hosted_zone_id"></a> [s3\_bucket\_hosted\_zone\_id](#output\_s3\_bucket\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket |
| <a name="output_s3_bucket_lifecycle_configuration_rules"></a> [s3\_bucket\_lifecycle\_configuration\_rules](#output\_s3\_bucket\_lifecycle\_configuration\_rules) | The lifecycle rules of the bucket, if the bucket is configured with lifecycle rules |
| <a name="output_s3_bucket_policy"></a> [s3\_bucket\_policy](#output\_s3\_bucket\_policy) | The policy of the bucket, if the bucket is configured with a policy |
| <a name="output_s3_bucket_region"></a> [s3\_bucket\_region](#output\_s3\_bucket\_region) | The AWS region this bucket resides in |
| <a name="output_s3_bucket_tags"></a> [s3\_bucket\_tags](#output\_s3\_bucket\_tags) | Tags of the bucket |
| <a name="output_s3_bucket_website_domain"></a> [s3\_bucket\_website\_domain](#output\_s3\_bucket\_website\_domain) | The domain of the website endpoint, if the bucket is configured with a website. This is used to create Route 53 alias records |
| <a name="output_s3_bucket_website_endpoint"></a> [s3\_bucket\_website\_endpoint](#output\_s3\_bucket\_website\_endpoint) | The website endpoint, if the bucket is configured with a website |
| <a name="output_s3_directory_bucket_arn"></a> [s3\_directory\_bucket\_arn](#output\_s3\_directory\_bucket\_arn) | ARN of the directory bucket |
| <a name="output_s3_directory_bucket_name"></a> [s3\_directory\_bucket\_name](#output\_s3\_directory\_bucket\_name) | Name of the directory bucket |
<!-- END_TF_DOCS -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/LICENSE) for full details.

## Additional information for users from Russia and Belarus

* Russia has [illegally annexed Crimea in 2014](https://en.wikipedia.org/wiki/Annexation_of_Crimea_by_the_Russian_Federation) and [brought the war in Donbas](https://en.wikipedia.org/wiki/War_in_Donbas) followed by [full-scale invasion of Ukraine in 2022](https://en.wikipedia.org/wiki/2022_Russian_invasion_of_Ukraine).
* Russia has brought sorrow and devastations to millions of Ukrainians, killed hundreds of innocent people, damaged thousands of buildings, and forced several million people to flee.
* [Putin khuylo!](https://en.wikipedia.org/wiki/Putin_khuylo!)
