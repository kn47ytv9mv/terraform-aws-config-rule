variable "name" {
  default     = null
  description = "Name of the rule. If null, a unique name is generated."
}

variable "description" {
  default     = null
  description = "A description of the rule."
}

variable "source_identifier" {
  default     = null
  description = "Identifier of the rule's logic — for an AWS managed rule, its name (e.g. 'S3_BUCKET_PUBLIC_READ_PROHIBITED', 'IAM_ROOT_ACCESS_KEY_CHECK'). See AWS's list of managed rules for the full catalog."
}

variable "input_parameters" {
  default     = null
  description = "JSON object of parameters the rule's logic accepts, for a managed rule that takes any (most do not). If null, the rule uses its own defaults."
}

variable "maximum_execution_frequency" {
  default     = null
  description = "How often a periodic rule re-evaluates, independent of configuration changes (e.g. 'TwentyFour_Hours'). Only meaningful for a rule that supports periodic triggering; ignored otherwise. If null, AWS's own default applies."
}

variable "scope" {
  default     = null
  description = "Narrows which resources the rule evaluates. At most one of compliance_resource_id (a single resource) or compliance_resource_types (a list of resource types) is typically set, optionally combined with tag_key/tag_value to further narrow by tag. If null, the rule evaluates every resource type its source_identifier applies to."
  type = object({
    compliance_resource_id    = optional(string)
    compliance_resource_types = optional(list(string))
    tag_key                   = optional(string)
    tag_value                 = optional(string)
  })
}

variable "evaluation_modes" {
  default     = ["DETECTIVE"]
  description = "When the rule evaluates: 'DETECTIVE' (after a resource is created or changed, the classic behavior) and/or 'PROACTIVE' (before creation, against a CloudFormation template — needs a rule that actually supports proactive evaluation). Defaults to detective-only, the mode every rule supports."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the rule."
}
