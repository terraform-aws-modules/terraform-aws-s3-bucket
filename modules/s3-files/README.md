# AWS S3 Files Submodule

Terraform submodule for managing [Amazon S3 Files](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-files.html) resources — a feature released in April 2026 that allows an S3 bucket to be mounted as an NFS-style file system from inside a VPC.

This submodule creates:

- `aws_s3files_file_system` — attaches the S3 Files file system to a versioned S3 bucket
- `aws_s3files_mount_target` — one mount target per subnet, enabling multi-AZ deployments
- `aws_s3files_file_system_policy` — a resource-based policy controlling NFS client access

## Architecture

The submodule is intentionally **decoupled** from the root `terraform-aws-s3-bucket` module.  It accepts the ARN of an _existing_ S3 bucket via `s3_uri` rather than creating one itself, so teams can compose it with any bucket provisioning approach.

### Prerequisites

| Requirement | Reason |
|---|---|
| S3 bucket with versioning enabled | The S3 Files API rejects buckets that do not have versioning enabled |
| IAM role with S3 permissions | Passed via `role_arn`; the service uses this role to read/write objects on behalf of NFS clients |
| VPC, subnets, and security groups | Mount targets are VPC-attached ENIs; at least one subnet is required |
| AWS provider `>= 6.39` | The `aws_s3files_*` resources were introduced in this provider version |

### Destroy ordering

Because the S3 Files file system holds a reference to the S3 bucket, attempting to destroy the bucket before the file system is detached results in a `409 BucketHasS3FileSystemAttached` error.  When managing both resources in the same Terraform configuration, add `module.s3_bucket` to `depends_on` on the `module "s3_files"` block:

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  # ...

  depends_on = [
    aws_iam_role_policy.s3_files_bucket_access,
    module.s3_bucket,   # ensures file system is destroyed before the bucket
  ]
}
```

Terraform inverts `depends_on` during destroy, guaranteeing that all S3 Files resources are torn down before the bucket is deleted.

## Usage

### Basic

Minimum viable configuration — creates one mount target per subnet with a secure auto-generated file system policy (VPC-scoped, account-root principal):

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  s3_uri   = "arn:aws:s3:::my-versioned-bucket"
  role_arn = aws_iam_role.s3_files.arn

  vpc_id     = "vpc-0a1b2c3d4e5f"
  subnet_ids = ["subnet-aaa111", "subnet-bbb222"]

  security_group_ids = [aws_security_group.nfs.id]

  tags = {
    Environment = "production"
  }
}
```

### Advanced — static IPs and a custom file system policy

Pin static IPv4 addresses to specific mount targets and provide a fully custom resource-based policy:

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  s3_uri   = "arn:aws:s3:::my-versioned-bucket"
  role_arn = aws_iam_role.s3_files.arn

  vpc_id     = "vpc-0a1b2c3d4e5f"
  subnet_ids = ["subnet-aaa111", "subnet-bbb222"]

  security_group_ids = [aws_security_group.nfs.id]

  ip_address_type = "ipv4"
  mount_target_ipv4_addresses = {
    "subnet-aaa111" = "10.0.1.50"
    "subnet-bbb222" = "10.0.2.50"
  }

  # Provide a hand-crafted policy; module will NOT generate the default policy
  file_system_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowSpecificRoleClientMount"
        Effect    = "Allow"
        Principal = { AWS = aws_iam_role.nfs_client.arn }
        Action    = "s3files:ClientMount"
        Resource  = "*"
        Condition = {
          StringEquals = { "aws:SourceVpc" = "vpc-0a1b2c3d4e5f" }
        }
      }
    ]
  })

  tags = {
    Environment = "production"
  }
}
```

### Disable resource creation

Set `create = false` to skip all resource creation while keeping the module call in place (useful for conditional deployments or feature flags):

```hcl
module "s3_files" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/s3-files"

  create = false
}
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
