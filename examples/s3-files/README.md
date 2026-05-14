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
<!-- END_TF_DOCS -->
