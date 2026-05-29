# S3 Vectors Vector Bucket Submodule

Submodule to manage [Amazon S3 Vectors](https://aws.amazon.com/s3-vectors/) vector buckets, bucket policies, and vector indexes.

Amazon S3 Vectors is a vector embedding storage service built into Amazon S3 that enables you to store, query, and manage vector embeddings at scale directly in S3.

## Usage

### Vector Bucket

```hcl
module "vector_bucket" {
  source = "../../modules/vectors"

  vector_bucket_name = "my-vector-bucket"

  encryption_configuration = {
    sse_type    = "aws:kms"
    kms_key_arn = aws_kms_key.this.arn
  }

  tags = {
    Environment = "dev"
  }
}
```

### Vector Bucket with Policy

```hcl
module "vector_bucket" {
  source = "../../modules/vectors"

  vector_bucket_name = "my-vector-bucket"

  create_policy = true
  policy        = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "writeStatement"
      Effect = "Allow"
      Principal = {
        AWS = "123456789012"
      }
      Action   = ["s3vectors:PutVectors"]
      Resource = "*"
    }]
  })

  tags = {
    Environment = "dev"
  }
}
```

### Vector Bucket with Index

```hcl
module "vector_bucket" {
  source = "../../modules/vectors"

  vector_bucket_name = "my-vector-bucket"

  indexes = {
    my_index = {
      index_name      = "my-index"
      dimension       = 1536
      distance_metric = "cosine"

      encryption_configuration = {
        sse_type    = "aws:kms"
        kms_key_arn = aws_kms_key.this.arn
      }

      metadata_configuration = {
        non_filterable_metadata_keys = ["description", "notes"]
      }

      tags = {
        Environment = "dev"
      }
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.42 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.42 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3vectors_index.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3vectors_index) | resource |
| [aws_s3vectors_vector_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3vectors_vector_bucket) | resource |
| [aws_s3vectors_vector_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3vectors_vector_bucket_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create"></a> [create](#input\_create) | Whether to create the S3 Vectors vector bucket | `bool` | `true` | no |
| <a name="input_create_policy"></a> [create\_policy](#input\_create\_policy) | Whether to create the S3 Vectors vector bucket policy | `bool` | `false` | no |
| <a name="input_encryption_configuration"></a> [encryption\_configuration](#input\_encryption\_configuration) | Encryption configuration for the vector bucket | <pre>object({<br/>    sse_type    = string<br/>    kms_key_arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Boolean that indicates all indexes and vectors should be deleted from the vector bucket when the vector bucket is destroyed | `bool` | `false` | no |
| <a name="input_indexes"></a> [indexes](#input\_indexes) | A map of vector indexes to create in the vector bucket. Each key is an arbitrary index name used for resource naming. | <pre>map(object({<br/>    index_name      = string<br/>    dimension       = number<br/>    distance_metric = string<br/>    data_type       = optional(string, "float32")<br/>    tags            = optional(map(string), {})<br/>    encryption_configuration = optional(object({<br/>      sse_type    = string<br/>      kms_key_arn = optional(string)<br/>    }), null)<br/>    metadata_configuration = optional(object({<br/>      non_filterable_metadata_keys = list(string)<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | The policy document as a JSON string | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the vector bucket will be managed. Defaults to the region set in the provider configuration | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the vector bucket | `map(string)` | `{}` | no |
| <a name="input_vector_bucket_name"></a> [vector\_bucket\_name](#input\_vector\_bucket\_name) | Name of the S3 Vectors vector bucket | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_creation_time"></a> [creation\_time](#output\_creation\_time) | Date and time when the vector bucket was created |
| <a name="output_index_arns"></a> [index\_arns](#output\_index\_arns) | ARNs of the vector indexes |
| <a name="output_index_creation_times"></a> [index\_creation\_times](#output\_index\_creation\_times) | Date and time when the vector indexes were created |
| <a name="output_vector_bucket_arn"></a> [vector\_bucket\_arn](#output\_vector\_bucket\_arn) | ARN of the S3 Vectors vector bucket |
| <a name="output_vector_bucket_name"></a> [vector\_bucket\_name](#output\_vector\_bucket\_name) | Name of the S3 Vectors vector bucket |
<!-- END_TF_DOCS -->
