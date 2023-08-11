# Data queried from a widely used JS library
# https://github.com/jshttp/mime-types

locals {
  # Disable this feature if content_type is provided
  enable_content_type_detection = var.detect_content_type && var.content_type == null

  # Enable query to remote DB only when detection and query are enabled
  enable_query = local.enable_content_type_detection && var.query_mime_types

  # Mime types DB used by the JS library
  mime_types_url = "https://raw.githubusercontent.com/jshttp/mime-db/master/db.json"

  # Change between local copy of db or queried DB with HTTP data
  source = jsondecode(local.enable_query ? data.http.mime_types_db[0].response_body : file("${path.module}/mime_types/mime_types.json"))

  # Parse DB into map(extension => mime_type)
  mime_types = merge([for k, v in local.source : { for ext in v.extensions : ".${ext}" => k } if contains(keys(v), "extensions")]...)

  # Find content type for current object, return null if no regex match or not found
  content_type = try(lookup(local.mime_types, regex("\\.[^.]+$", var.key), null), null)
}

# Query mime types DB
data "http" "mime_types_db" {
  count = local.enable_query ? 1 : 0

  url             = local.mime_types_url
  request_headers = { Accept = "application/json" }
}
