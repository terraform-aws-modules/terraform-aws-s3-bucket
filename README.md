# AWS S3 bucket Terraform module

Terraform module which creates S3 bucket on AWS with all (or almost all) features provided by Terraform AWS provider.

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

## Usage

### Private bucket with versioning enabled

```hcl
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket"
  acl    = "private"

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

  attach_elb_log_delivery_policy = true
}
```

### Bucket with ALB/NLB access log delivery policy attached

```hcl
module "s3_bucket_for_logs" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "my-s3-bucket-for-logs"
  acl    = "log-delivery-write"

  # Allow deletion of non-empty bucket
  force_destroy = true

  attach_elb_log_delivery_policy = true  # Required for ALB logs
  attach_lb_log_delivery_policy  = true  # Required for ALB/NLB logs
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

## Terragrunt and `variable "..." { type = any }`

There is a bug [#1211](https://github.com/gruntwork-io/terragrunt/issues/1211) in Terragrunt related to the way how the variables of type `any` are passed to Terraform.

This module solves this issue by supporting `jsonencode()`-string in addition to the expected type (`list` or `map`).

In `terragrunt.hcl` you can write:

```terraform
inputs = {
  bucket    = "foobar"            # `bucket` has type `string`, no need to jsonencode()
  cors_rule = jsonencode([...])   # `cors_rule` has type `any`, so `jsonencode()` is required
}
```

## Examples:

- [Complete](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/complete) - Complete S3 bucket with most of supported features enabled
- [Cross-Region Replication](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-replication) - S3 bucket with Cross-Region Replication (CRR) enabled
- [S3 Bucket Notifications](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/notification) - S3 bucket notifications to Lambda functions, SQS queues, and SNS topics.
- [S3 Bucket Object](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/object) - Manage S3 bucket objects.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.26 |
| aws | >= 3.50 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.50 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acceleration\_status | (Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended. | `string` | `null` | no |
| acl | (Optional) The canned ACL to apply. Defaults to 'private'. Conflicts with `grant` | `string` | `"private"` | no |
| attach\_deny\_insecure\_transport\_policy | Controls if S3 bucket should have deny non-SSL transport policy attached | `bool` | `false` | no |
| attach\_elb\_log\_delivery\_policy | Controls if S3 bucket should have ELB log delivery policy attached | `bool` | `false` | no |
| attach\_lb\_log\_delivery\_policy | Controls if S3 bucket should have ALB/NLB log delivery policy attached | `bool` | `false` | no |
| attach\_policy | Controls if S3 bucket should have bucket policy attached (set to `true` to use value of `policy` as bucket policy) | `bool` | `false` | no |
| attach\_public\_policy | Controls if a user defined public bucket policy will be attached (set to `false` to allow upstream to apply defaults to the bucket) | `bool` | `true` | no |
| block\_public\_acls | Whether Amazon S3 should block public ACLs for this bucket. | `bool` | `false` | no |
| block\_public\_policy | Whether Amazon S3 should block public bucket policies for this bucket. | `bool` | `false` | no |
| bucket | (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. | `string` | `null` | no |
| bucket\_prefix | (Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | `string` | `null` | no |
| cors\_rule | List of maps containing rules for Cross-Origin Resource Sharing. | `any` | `[]` | no |
| create\_bucket | Controls if S3 bucket should be created | `bool` | `true` | no |
| force\_destroy | (Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| grant | An ACL policy grant. Conflicts with `acl` | `any` | `[]` | no |
| ignore\_public\_acls | Whether Amazon S3 should ignore public ACLs for this bucket. | `bool` | `false` | no |
| lifecycle\_rule | List of maps containing configuration of object lifecycle management. | `any` | `[]` | no |
| logging | Map containing access bucket logging configuration. | `map(string)` | `{}` | no |
| object\_lock\_configuration | Map containing S3 object locking configuration. | `any` | `{}` | no |
| policy | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| replication\_configuration | Map containing cross-region replication configuration. | `any` | `{}` | no |
| request\_payer | (Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information. | `string` | `null` | no |
| restrict\_public\_buckets | Whether Amazon S3 should restrict public bucket policies for this bucket. | `bool` | `false` | no |
| server\_side\_encryption\_configuration | Map containing server-side encryption configuration. | `any` | `{}` | no |
| tags | (Optional) A mapping of tags to assign to the bucket. | `map(string)` | `{}` | no |
| versioning | Map containing versioning configuration. | `map(string)` | `{}` | no |
| website | Map containing static web-site hosting or redirect configuration. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_bucket\_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| s3\_bucket\_bucket\_domain\_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| s3\_bucket\_bucket\_regional\_domain\_name | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| s3\_bucket\_hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| s3\_bucket\_id | The name of the bucket. |
| s3\_bucket\_region | The AWS region this bucket resides in. |
| s3\_bucket\_website\_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| s3\_bucket\_website\_endpoint | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module is maintained by [Anton Babenko](https://github.com/antonbabenko) with help from [these awesome contributors](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/LICENSE) for full details.
