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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 2 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_all_notifications"></a> [all\_notifications](#module\_all\_notifications) | ../../modules/notification |  |
| <a name="module_lambda_function1"></a> [lambda\_function1](#module\_lambda\_function1) | terraform-aws-modules/lambda/aws | ~> 1.0 |
| <a name="module_lambda_function2"></a> [lambda\_function2](#module\_lambda\_function2) | terraform-aws-modules/lambda/aws | ~> 1.0 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | ../../ |  |
| <a name="module_sns_topic1"></a> [sns\_topic1](#module\_sns\_topic1) | terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_sns_topic |  |
| <a name="module_sns_topic2"></a> [sns\_topic2](#module\_sns\_topic2) | terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_sns_topic |  |

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.allow_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [null_resource.download_package](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_pet.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_iam_policy_document.sqs_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [null_data_source.downloaded_package](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_this_s3_bucket_arn"></a> [this\_s3\_bucket\_arn](#output\_this\_s3\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_this_s3_bucket_bucket_domain_name"></a> [this\_s3\_bucket\_bucket\_domain\_name](#output\_this\_s3\_bucket\_bucket\_domain\_name) | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| <a name="output_this_s3_bucket_bucket_regional_domain_name"></a> [this\_s3\_bucket\_bucket\_regional\_domain\_name](#output\_this\_s3\_bucket\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| <a name="output_this_s3_bucket_hosted_zone_id"></a> [this\_s3\_bucket\_hosted\_zone\_id](#output\_this\_s3\_bucket\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_this_s3_bucket_id"></a> [this\_s3\_bucket\_id](#output\_this\_s3\_bucket\_id) | The name of the bucket. |
| <a name="output_this_s3_bucket_region"></a> [this\_s3\_bucket\_region](#output\_this\_s3\_bucket\_region) | The AWS region this bucket resides in. |
| <a name="output_this_s3_bucket_website_domain"></a> [this\_s3\_bucket\_website\_domain](#output\_this\_s3\_bucket\_website\_domain) | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| <a name="output_this_s3_bucket_website_endpoint"></a> [this\_s3\_bucket\_website\_endpoint](#output\_this\_s3\_bucket\_website\_endpoint) | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
