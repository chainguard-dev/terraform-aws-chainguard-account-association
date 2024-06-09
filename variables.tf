variable "environment" {
  default     = "enforce.dev"
  type        = string
  description = "Domain of the Chainguard environment"
  sensitive   = false
  nullable    = false
}

variable "group_ids" {
  type        = list(string)
  description = "Chainguard IAM group IDs to bind your AWS account to."
  sensitive   = false
}

variable "account" {
  type        = string
  description = "The AWS account ID to which we are binding the Chainguard groups."
  sensitive   = false
}
