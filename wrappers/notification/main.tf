module "wrapper" {
  source = "../../modules/notification"

  for_each = var.items

  create               = lookup(each.value, "create", true)
  create_sns_policy    = lookup(each.value, "create_sns_policy", true)
  create_sqs_policy    = lookup(each.value, "create_sqs_policy", true)
  bucket               = lookup(each.value, "bucket", "")
  bucket_arn           = lookup(each.value, "bucket_arn", null)
  lambda_notifications = lookup(each.value, "lambda_notifications", {})
  sqs_notifications    = lookup(each.value, "sqs_notifications", {})
  sns_notifications    = lookup(each.value, "sns_notifications", {})
}
