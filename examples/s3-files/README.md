# S3 Files Example

Configuration in this directory demonstrates a complete, production-ready deployment of the [`modules/s3-files`](../../modules/s3-files) submodule against a real AWS account.

The example was validated against AWS provider `6.45.0` in `eu-west-1`.  All resources were successfully applied and cleanly destroyed (see [apply.md](apply.md) and [destroy.md](destroy.md) for the captured CLI output).

## What this example creates

| Resource | Description |
|---|---|
| `aws_vpc` | Dedicated VPC (`10.42.0.0/16`) with DNS support enabled |
| `aws_subnet.private_a/b` | Two private subnets in different AZs, one per mount target |
| `aws_security_group.s3_files` | Security group attached to every mount target; allows NFS ingress (TCP 2049) from the VPC CIDR and unrestricted egress |
| `aws_iam_role.s3_files` | IAM role assumed by S3 Files (trust: `elasticfilesystem.amazonaws.com`) |
| `aws_iam_role_policy` | Inline policy granting `ListBucket` / object CRUD on the example bucket |
| `module.s3_bucket` | S3 bucket from the parent module, versioning enabled, `force_destroy = true` |
| `module.s3_files` | S3 Files file system + two mount targets + auto-generated VPC-scoped policy + one access point (`test-app-ap`) |
| `aws_s3files_access_point` | Access point with POSIX UID/GID 1000, root directory `/test-app-data`, permissions `0755` |

The bucket name is randomised with `random_pet` to avoid naming conflicts across runs.

## Usage

```bash
terraform init
terraform plan
terraform apply
```

> **Note:** this example creates billable AWS resources (VPC, subnets, IAM role, S3 bucket, S3 Files file system, and mount targets).  Run `terraform destroy` when the resources are no longer needed.

## Destroy ordering

Amazon S3 raises a `409 BucketHasS3FileSystemAttached` error if you attempt to delete a bucket while a file system is still attached to it.  This example resolves the ordering issue by declaring `depends_on = [module.s3_bucket]` on the `module "s3_files"` block.  Terraform inverts `depends_on` during destroy, ensuring the file system and its mount targets are removed _before_ the bucket is deleted.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.39 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.39 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../../ | n/a |
| <a name="module_s3_files"></a> [s3\_files](#module\_s3\_files) | ../../modules/s3-files | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.s3_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.s3_files_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_security_group.s3_files](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_b](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.s3_files_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_files_bucket_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the example resources | `string` | `"eu-west-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the bucket. |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_s3_bucket_versioning_status"></a> [s3\_bucket\_versioning\_status](#output\_s3\_bucket\_versioning\_status) | Versioning status of the example S3 bucket. |
| <a name="output_s3_files_access_points"></a> [s3\_files\_access\_points](#output\_s3\_files\_access\_points) | Map of S3 Files access points (id and arn) created by the example. |
| <a name="output_s3_files_file_system_arn"></a> [s3\_files\_file\_system\_arn](#output\_s3\_files\_file\_system\_arn) | ARN of the S3 Files file system. |
| <a name="output_s3_files_file_system_id"></a> [s3\_files\_file\_system\_id](#output\_s3\_files\_file\_system\_id) | Identifier of the S3 Files file system. |
| <a name="output_s3_files_mount_target_network_interface_ids"></a> [s3\_files\_mount\_target\_network\_interface\_ids](#output\_s3\_files\_mount\_target\_network\_interface\_ids) | List of mount target network interface IDs. |
<!-- END_TF_DOCS -->
