resource "random_uuid" "resource" {}

resource "aws_config_config_rule" "resource" {
  name                        = coalesce(var.name, random_uuid.resource.id)
  description                 = var.description
  input_parameters            = var.input_parameters
  maximum_execution_frequency = var.maximum_execution_frequency

  source {
    owner             = "AWS"
    source_identifier = var.source_identifier
  }

  dynamic "scope" {
    for_each = var.scope[*]

    content {
      compliance_resource_id    = scope.value.compliance_resource_id
      compliance_resource_types = scope.value.compliance_resource_types
      tag_key                   = scope.value.tag_key
      tag_value                 = scope.value.tag_value
    }
  }

  dynamic "evaluation_mode" {
    for_each = toset(var.evaluation_modes)

    content {
      mode = evaluation_mode.value
    }
  }

  tags = var.tags
}

output "id" {
  description = "The ID of the rule."
  value       = aws_config_config_rule.resource.id
}

output "name" {
  description = "The name of the rule."
  value       = aws_config_config_rule.resource.name
}

output "arn" {
  description = "The ARN of the rule."
  value       = aws_config_config_rule.resource.arn
}

output "rule_id" {
  description = "AWS's own internal ID for the rule, distinct from its name."
  value       = aws_config_config_rule.resource.rule_id
}
