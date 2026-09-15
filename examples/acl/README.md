# S3 bucket ACLs

Configuration in this directory demonstrates the ACL surface of the module: canned ACLs,
explicit grants and bucket ownership settings other than the default.

AWS recommends disabling ACLs, and this module defaults `object_ownership` to
`BucketOwnerEnforced`, which rejects `acl`, `grant` and `owner` outright. This example
exists for the workloads that still require them, chiefly CloudFront standard logging
(legacy). Standard logging (v2) uses a bucket policy and needs none of this.

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

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

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_acl_canned"></a> [acl\_canned](#module\_acl\_canned) | ../../ | n/a |
| <a name="module_cloudfront_log_bucket"></a> [cloudfront\_log\_bucket](#module\_cloudfront\_log\_bucket) | ../../ | n/a |
| <a name="module_object_acl"></a> [object\_acl](#module\_object\_acl) | ../../modules/object | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_log_delivery_canonical_user_id.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_log_delivery_canonical_user_id) | data source |

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
