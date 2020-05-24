locals {
  bucket_name = "s3-bucket-${random_pet.this.id}"
}

resource "random_pet" "this" {
  length = 2
}

module "s3_bucket" {
  source = "../../"

  bucket        = local.bucket_name
  force_destroy = true
}

module "lambda_function1" {
  source = "terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_lambda_function"
}

module "lambda_function2" {
  source = "terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_lambda_function"
}

module "sns_topic1" {
  source = "terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_sns_topic"
}

module "sns_topic2" {
  source = "terraform-aws-modules/cloudwatch/aws//examples/fixtures/aws_sns_topic"
}

resource "aws_sqs_queue" "this" {
  count = 2
  name  = "${random_pet.this.id}-${count.index}"
}

module "all_notifications" {
  source = "../../modules/notification"

  bucket = module.s3_bucket.this_s3_bucket_id
  create = false

  // Common error - Error putting S3 notification configuration: InvalidArgument: Configuration is ambiguously defined. Cannot have overlapping suffixes in two rules if the prefixes are overlapping for the same event type.

  lambda_notifications = {
    lambda1 = {
      lambda_function_arn = module.lambda_function1.this_lambda_function_arn
      events              = ["s3:ObjectCreated:Put"]
      filter_prefix       = "prefix/"
      filter_suffix       = ".json"
    }

    lambda2 = {
      lambda_function_arn = module.lambda_function2.this_lambda_function_arn
      events              = ["s3:ObjectCreated:Post"]
    }
  }

  sqs_notifications = {
    sqs1 = {
      queue_arn     = aws_sqs_queue.this[0].arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "prefix2/"
      filter_suffix = ".txt"

      //      queue_id =  aws_sqs_queue.this[0].id // optional
    }

    sqs2 = {
      queue_arn = aws_sqs_queue.this[1].arn
      events    = ["s3:ObjectCreated:Copy"]
    }
  }

  sns_notifications = {
    sns1 = {
      topic_arn     = module.sns_topic1.this_sns_topic_arn
      events        = ["s3:ObjectRemoved:Delete"]
      filter_prefix = "prefix3/"
      filter_suffix = ".csv"
    }

    sns2 = {
      topic_arn = module.sns_topic2.this_sns_topic_arn
      events    = ["s3:ObjectRemoved:DeleteMarkerCreated"]
    }
  }

}
