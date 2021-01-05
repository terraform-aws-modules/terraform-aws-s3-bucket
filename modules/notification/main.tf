locals {
  bucket_arn = coalesce(var.bucket_arn, "arn:aws:s3:::${var.bucket}")

  # Convert from "arn:aws:sqs:eu-west-1:835367859851:bold-starling-0" into "https://sqs.eu-west-1.amazonaws.com/835367859851/bold-starling-0" if queue_id was not specified
  # queue_url used in aws_sqs_queue_policy is not the same as arn which is used in all other places
  queue_ids = { for k, v in var.sqs_notifications : k => format("https://%s.%s.amazonaws.com/%s/%s", data.aws_arn.queue[k].service, data.aws_arn.queue[k].region, data.aws_arn.queue[k].account, data.aws_arn.queue[k].resource) if lookup(v, "queue_id", "") == "" }
}

resource "aws_s3_bucket_notification" "this" {
  count = var.create && (length(var.lambda_notifications) > 0 || length(var.sqs_notifications) > 0 || length(var.sns_notifications) > 0) ? 1 : 0

  bucket = var.bucket

  dynamic "lambda_function" {
    for_each = var.lambda_notifications

    content {
      id                  = lambda_function.key
      lambda_function_arn = lambda_function.value.function_arn
      events              = lambda_function.value.events
      filter_prefix       = lookup(lambda_function.value, "filter_prefix", null)
      filter_suffix       = lookup(lambda_function.value, "filter_suffix", null)
    }
  }

  dynamic "queue" {
    for_each = var.sqs_notifications

    content {
      id            = queue.key
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = lookup(queue.value, "filter_prefix", null)
      filter_suffix = lookup(queue.value, "filter_suffix", null)
    }
  }

  dynamic "topic" {
    for_each = var.sns_notifications

    content {
      id            = topic.key
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = lookup(topic.value, "filter_prefix", null)
      filter_suffix = lookup(topic.value, "filter_suffix", null)
    }
  }

  depends_on = [
    aws_lambda_permission.allow,
    aws_sqs_queue_policy.allow,
    aws_sns_topic_policy.allow,
  ]
}

# Lambda
resource "aws_lambda_permission" "allow" {
  for_each = var.lambda_notifications

  statement_id_prefix = "AllowLambdaS3BucketNotification-"
  action              = "lambda:InvokeFunction"
  function_name       = each.value.function_name
  qualifier           = lookup(each.value, "qualifier", null)
  principal           = "s3.amazonaws.com"
  source_arn          = local.bucket_arn
}

# SQS Queue
data "aws_arn" "queue" {
  for_each = var.sqs_notifications

  arn = each.value.queue_arn
}

data "aws_iam_policy_document" "sqs" {
  for_each = var.create_sqs_policy ? var.sqs_notifications : tomap({})

  statement {
    sid = "AllowSQSS3BucketNotification"

    effect = "Allow"

    actions = [
      "sqs:SendMessage",
    ]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [each.value.queue_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.bucket_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "allow" {
  for_each = var.create_sqs_policy ? var.sqs_notifications : tomap({})

  queue_url = lookup(each.value, "queue_id", lookup(local.queue_ids, each.key, null))
  policy    = data.aws_iam_policy_document.sqs[each.key].json
}

# SNS Topic
data "aws_iam_policy_document" "sns" {
  for_each = var.create_sns_policy ? var.sns_notifications : tomap({})

  statement {
    sid = "AllowSNSS3BucketNotification"

    effect = "Allow"

    actions = [
      "sns:Publish",
    ]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [each.value.topic_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.bucket_arn]
    }
  }
}

resource "aws_sns_topic_policy" "allow" {
  for_each = var.create_sns_policy ? var.sns_notifications : tomap({})

  arn    = each.value.topic_arn
  policy = data.aws_iam_policy_document.sns[each.key].json
}
