# S3 bucket notifications to Lambda functions, SQS queues, and SNS topics

Configuration in this directory creates S3 bucket notifications to all supported destinations.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.26 |
| aws | >= 3.0 |
| null | >= 2 |
| random | >= 2 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |
| null | >= 2 |
| random | >= 2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| all_notifications | ../../modules/notification |  |
| lambda_function1 | terraform-aws-modules/lambda/aws | ~> 1.0 |
| lambda_function2 | terraform-aws-modules/lambda/aws | ~> 1.0 |
| s3_bucket | ../../ |  |
| sns_topic1 | terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_sns_topic |  |
| sns_topic2 | terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_sns_topic |  |

## Resources

| Name |
|------|
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) |
| [aws_sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) |
| [null_data_source](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |
| [random_pet](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) |

## Inputs

No input.

## Outputs

| Name | Description |
|------|-------------|
| this\_s3\_bucket\_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| this\_s3\_bucket\_bucket\_domain\_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| this\_s3\_bucket\_bucket\_regional\_domain\_name | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| this\_s3\_bucket\_hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| this\_s3\_bucket\_id | The name of the bucket. |
| this\_s3\_bucket\_region | The AWS region this bucket resides in. |
| this\_s3\_bucket\_website\_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| this\_s3\_bucket\_website\_endpoint | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
