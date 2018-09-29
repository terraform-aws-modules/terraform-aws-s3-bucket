resource "aws_s3_bucket" "this" {
    count   = "${var.count}"
    bucket  = "${var.name}"
    acl     = "${var.acl}"
    tags    = "${merge(var.tags, map("Name", "${var.name}"))}"

    website = "${var.website}"
}
