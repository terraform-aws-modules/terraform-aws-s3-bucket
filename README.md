# AWS S3 bucket Terraform module

Terraform module which creates S3 bucket resources on AWS.

This type of resources are supported:

* [S3 bucket](https://www.terraform.io/docs/providers/aws/r/s3_bucket.html)

These S3 Bucket configurations are supported:

- cors
- lifecycle-rules
- logging
- replication (Cross Region Replication - CRR)*
- versioning
- website

```
These configurations are not supported yet:

In Cross Region Replication (in replication_configuration/rules block):
- priority (the argument is not supported yet).
- filter (the argument is not supported yet).

Object Lock Configuration block(object_lock_configuration) (this configuration block is not supported yet).
```

## Terraform versions

Only Terraform 0.12 is supported.

## Usage

- **Private Bucket**

```hcl
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "s3-tf-example-versioning"
  acl    = "private"

  versioning_inputs = [
    {
      enabled = true
      mfa_delete = null
    },
  ]
}
```

## Examples:

* [S3-CORS](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-cors)
* [S3-Lifecycle-Rules](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-lifecycle-rules)
* [S3-Logging](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-logging)
* [S3-Replication](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-replication)
* [S3-Versioning](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-versioning)
* [S3-Website](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/tree/master/examples/s3-website)

## Inputs notes
```
The Terraform "aws_s3_bucket" resource has some nested configuration blocks and this was translated
to this module as lists of objects. Each configuration block was renamed as it follows: 
<CONFIG_BLOCK_NAME>_inputs
``` 
  

```
module "aws_s3_bucket" {
  source = "../.."
  bucket = "s3-tf-example-logging"
  acl    = "private"

  logging_inputs = [
  {
    target_bucket = "s3-tf-example-logger"
    target_prefix = "log/"
  },
  ]
```
The **logging_inputs** list will be converted to a **logging** configuration block:
```
logging {
  target_bucket = "s3-tf-example-logger"
  target_prefix = "log/"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acceleration\_status | (Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended. | string | `"null"` | no |
| acl | (Optional) The canned ACL to apply. Defaults to 'private'. | string | `"private"` | no |
| bucket | (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. | string | `"null"` | no |
| bucket\_prefix | (Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | string | `"null"` | no |
| cors\_rule\_inputs |  | object | `"null"` | no |
| force\_destroy | (Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | string | `"false"` | no |
| lifecycle\_rule\_inputs |  | object | `"null"` | no |
| logging\_inputs |  | object | `"null"` | no |
| object\_lock\_configuration\_inputs |  | object | `"null"` | no |
| policy | (Optional) A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. | string | `"null"` | no |
| region | (Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee. | string | `"null"` | no |
| replication\_configuration\_inputs |  | object | `"null"` | no |
| request\_payer | (Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information. | string | `"null"` | no |
| server\_side\_encryption\_configuration\_inputs |  | object | `"null"` | no |
| tags | (Optional) A mapping of tags to assign to the bucket. | map | `{}` | no |
| versioning\_inputs |  | object | `"null"` | no |
| website\_inputs |  | object | `"null"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket\_domain\_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| bucket\_regional\_domain\_name | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| id | The name of the bucket. |
| region | The AWS region this bucket resides in. |
| website\_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| website\_endpoint | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Anton Babenko](https://github.com/antonbabenko).

## License

Apache 2 Licensed. See LICENSE for full details.
