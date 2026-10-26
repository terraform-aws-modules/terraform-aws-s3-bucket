variable "attach_deny_insecure_transport_policy" {
  description = "Attach a policy denying insecure transport to the canned-ACL bucket; toggling this must preserve its ownership controls and ACL"
  type        = bool
  default     = false
}
