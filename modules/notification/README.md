# S3 bucket notification

Creates S3 bucket notification resource with all supported types of deliveries: AWS Lambda, SQS Queue, SNS Topic.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.6 |
| aws | >= 3.0 |
| random | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) |
| [aws_iam_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) |
| [aws_lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) |
| [aws_s3_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) |
| [aws_sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) |
| [aws_sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket | Name of S3 bucket to use | `string` | `""` | no |
| bucket\_arn | ARN of S3 bucket to use in policies | `string` | `null` | no |
| create | Whether to create this resource or not? | `bool` | `true` | no |
| create\_sns\_policy | Whether to create a policy for SNS permissions or not? | `bool` | `true` | no |
| create\_sqs\_policy | Whether to create a policy for SQS permissions or not? | `bool` | `true` | no |
| lambda\_notifications | Map of S3 bucket notifications to Lambda function | `any` | `{}` | no |
| sns\_notifications | Map of S3 bucket notifications to SNS topic | `any` | `{}` | no |
| sqs\_notifications | Map of S3 bucket notifications to SQS queue | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_s3\_bucket\_notification\_id | ID of S3 bucket |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
