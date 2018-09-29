variable "name" {
    description = "Name to be used on all the resources as identifier"
    default     = ""
}

variable "count" {
    description = "How many buckets should be created"
    default     = 1
}

variable "tags" {
    description = "Additional tags for the bucket"
    type        = "map"
    default     = {}
}

variable "acl" {
    description = "Name to be used on all the resources as identifier"
    default     = "private"
}

variable "website" {
    description = "The static website to be hosted"
    type        = "list"
    default     = []
}
