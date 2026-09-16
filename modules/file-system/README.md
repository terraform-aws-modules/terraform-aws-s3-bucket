# Amazon S3 Files File System

Creates an Amazon S3 Files file system on a general purpose bucket, with its IAM role, mount targets, access points, file system policy and synchronization configuration.

The bucket must have versioning enabled. Pass the versioning resource's own status rather than a literal, so the file system is created after versioning and deleted before it is suspended:

```hcl
module "file_system" {
  source = "terraform-aws-modules/s3-bucket/aws//modules/file-system"

  name                     = "training"
  bucket_arn               = aws_s3_bucket.this.arn
  bucket_versioning_status = aws_s3_bucket_versioning.this.versioning_configuration[0].status

  security_group_vpc_id = "vpc-1234556abcdef"
  security_group_ingress_rules = {
    clients = {
      referenced_security_group_id = "sg-1234556abcdef"
    }
  }

  mount_targets = {
    "eu-west-1a" = { subnet_id = "subnet-1234556abcdef" }
  }
}
```

When the bucket is created by the root module, use its `file_systems` input instead, which calls this module for each entry.
