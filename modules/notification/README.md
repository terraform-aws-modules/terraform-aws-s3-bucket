# S3 bucket notification

Creates S3 bucket notification resource with all supported types of deliveries: AWS Lambda, SQS Queue, SNS Topic.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket | Name of S3 bucket to use | `string` | `""` | no |
| bucket\_arn | ARN of S3 bucket to use in policies | `string` | `null` | no |
| create | Whether to create this resource or not? | `bool` | `true` | no |
| lambda\_notifications | Map of S3 bucket notifications to Lambda function | `any` | `{}` | no |
| sns\_notifications | Map of S3 bucket notifications to SNS topic | `any` | `{}` | no |
| sqs\_notifications | Map of S3 bucket notifications to SQS queue | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| this\_s3\_bucket\_notification\_id | ID of S3 bucket |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
