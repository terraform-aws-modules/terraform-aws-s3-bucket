variable "items" {
  description = "Maps of items to create a wrapper from. Values are passed through to the module."
  type        = map(any)
  default     = {}
}
