variable "enforce_domain_name" {
  default     = "enforce.dev"
  type        = string
  description = "Domain name of your Chainguard Enforce environment"
  sensitive   = false
  nullable    = false
}

variable "enforce_group_id" {
  type        = string
  description = "DEPRECATED: Please use 'enforce_group_ids'. Enforce IAM group ID to bind your AWS account to"
  default     = ""
  sensitive   = false
  nullable    = false

  validation {
    condition     = var.enforce_group_id != "" ? length(regexall("^[a-f0-9]{40}(\\/[a-f0-9]{16})*$", var.enforce_group_id)) == 1 : true
    error_message = "The value 'enforce_group_id' must be a valid group id."
  }
}

variable "enforce_group_ids" {
  type        = list(string)
  description = "Enforce IAM group IDs to bind your AWS account to. If both 'enforce_group_id' and 'enforce_group_ids' are specified, 'enforce_group_id' is ignored."
  sensitive   = false
  default     = []

  validation {
    condition     = can([for g in var.enforce_group_ids : regex("^[a-f0-9]{40}(\\/[a-f0-9]{16})*$", g)])
    error_message = "IDs in enforce_group_ids must be a valid group id."
  }
}
