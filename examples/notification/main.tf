provider "aws" {
  region = local.region
}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  tags = {
    Name       = local.name
    Example    = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-s3-bucket"
  }
}


################################################################################
# S3 Bucket Notifications
################################################################################

module "all_notifications" {
  source = "../../modules/notification"

  region = local.region

  bucket = module.s3_bucket.s3_bucket_id

  eventbridge = true

  # Common error - Error putting S3 notification configuration: InvalidArgument: Configuration is ambiguously defined. Cannot have overlapping suffixes in two rules if the prefixes are overlapping for the same event type.

  lambda_notifications = {
    lambda1 = {
      function_arn  = module.lambda_function1.lambda_function_arn
      function_name = module.lambda_function1.lambda_function_name
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "prefix/"
      filter_suffix = ".json"
    }

    lambda2 = {
      function_arn  = module.lambda_function2.lambda_function_arn
      function_name = module.lambda_function2.lambda_function_name
      events        = ["s3:ObjectCreated:Post"]
    }
  }

  sqs_notifications = {
    sqs1 = {
      queue_arn     = aws_sqs_queue.this[0].arn
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "prefix2/"
      filter_suffix = ".txt"

      #      queue_id =  aws_sqs_queue.this[0].id // optional
    }
  }

  sns_notifications = {
    sns1 = {
      topic_arn     = module.sns_topic1.topic_arn
      events        = ["s3:ObjectRemoved:Delete"]
      filter_prefix = "prefix3/"
      filter_suffix = ".csv"
    }

    sns2 = {
      topic_arn = module.sns_topic2.topic_arn
      events    = ["s3:ObjectRemoved:DeleteMarkerCreated"]
    }
  }

  # Creation of policy is handled outside of the module
  create_sqs_policy = false
}

################################################################################
# Bucket ARN and Caller Managed Policies
################################################################################

# S3 permits a single notification configuration per bucket, so this needs its own bucket
# rather than a second configuration on the one above.
#
# `bucket_arn` is an alternative to deriving the ARN from `bucket`, useful when the bucket is
# in another account. The create_* toggles turn off the policies this module would otherwise
# manage, for callers who attach their own.
module "caller_managed_policies" {
  source = "../../modules/notification"

  region = local.region

  bucket     = module.caller_managed_bucket.s3_bucket_id
  bucket_arn = module.caller_managed_bucket.s3_bucket_arn

  create_lambda_permission = false
  create_sns_policy        = false
  create_sqs_policy        = false

  eventbridge = true
}

################################################################################
# Disabled
################################################################################

module "disabled" {
  source = "../../modules/notification"

  create = false
}

################################################################################
# Supporting Resources
################################################################################

module "s3_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-"

  # For example only
  force_destroy = true


  tags = local.tags
}

module "caller_managed_bucket" {
  source = "../../"

  bucket_prefix = "${local.name}-caller-"

  # For example only
  force_destroy = true

  tags = local.tags
}

# The functions are built from a package downloaded at apply time
locals {
  package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
  downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
}

resource "null_resource" "download_package" {
  triggers = {
    downloaded = local.downloaded
  }

  provisioner "local-exec" {
    command = "curl -L -o ${local.downloaded} ${local.package_url}"
  }
}

module "lambda_function1" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.0"

  function_name = "${local.name}-lambda1"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  create_package         = false
  local_existing_package = local.downloaded

  tags = local.tags
}

module "lambda_function2" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 8.0"

  function_name = "${local.name}-lambda2"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  create_package         = false
  local_existing_package = local.downloaded

  tags = local.tags
}

module "sns_topic1" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 7.0"

  # The notification sub-module below manages this topic\'s policy; letting the sns
  # module create one too makes both fight over the same resource on every apply
  create_topic_policy = false

  name            = "${local.name}-2"
  use_name_prefix = true

  tags = local.tags
}

module "sns_topic2" {
  source  = "terraform-aws-modules/sns/aws"
  version = "~> 7.0"

  # The notification sub-module below manages this topic\'s policy; letting the sns
  # module create one too makes both fight over the same resource on every apply
  create_topic_policy = false

  name            = "${local.name}-2"
  use_name_prefix = true

  tags = local.tags
}

resource "aws_sqs_queue" "this" {
  count = 2
  name  = "${local.name}-${count.index}"
}

# SQS policy created outside of the module
data "aws_iam_policy_document" "sqs_external" {
  statement {
    effect  = "Allow"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [aws_sqs_queue.this[0].arn]
  }
}

resource "aws_sqs_queue_policy" "allow_external" {
  queue_url = aws_sqs_queue.this[0].id
  policy    = data.aws_iam_policy_document.sqs_external.json
}
