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

## Ownership controls regression

The canned-ACL bucket starts without a bucket policy. After applying the example
in a test account, add its first policy:

```bash
terraform plan -var='attach_deny_insecure_transport_policy=true'
terraform apply -var='attach_deny_insecure_transport_policy=true'
terraform plan
```

The first plan must only create a bucket policy; the final plan must only remove
that policy. Neither plan should replace ownership controls or change either
bucket or its ACL. Apply the final plan to remove the policy, then destroy the
example resources when finished.

To check the example's policy toggle without AWS credentials (Terraform >= 1.7):

```bash
terraform init -backend=false
terraform test
```

This example test uses a mock provider. The root module's
`tests/ownership-controls.tftest.hcl` separately checks replacement behavior with
real-provider offline plans against mock-seeded state, with and without ACLs.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.44 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.44 |

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

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_attach_deny_insecure_transport_policy"></a> [attach\_deny\_insecure\_transport\_policy](#input\_attach\_deny\_insecure\_transport\_policy) | Attach a policy denying insecure transport to the canned-ACL bucket; toggling this must preserve its ownership controls and ACL | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
