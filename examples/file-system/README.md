# S3 file system

Configuration in this directory creates an S3 bucket with two Amazon S3 Files file systems scoped to separate prefixes of the same bucket. The `training` file system preloads small files for a machine learning training workload and uses the module's shared security group. The `agents` file system imports metadata only, uses its own security group, and exposes an access point for an IAM role.

## Usage

To run this example you need to execute:

```bash
terraform init
terraform plan
terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
