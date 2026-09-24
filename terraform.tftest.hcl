mock_provider "aws" {
}

run "default_config_creates_detective_rule" {
  command = apply

  variables {
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  assert {
    condition     = aws_config_config_rule.resource.source[0].owner == "AWS"
    error_message = "owner should always be 'AWS' — this module only supports AWS managed rules."
  }

  assert {
    condition     = aws_config_config_rule.resource.source[0].source_identifier == "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    error_message = "source_identifier should pass through unchanged."
  }

  assert {
    condition     = length(aws_config_config_rule.resource.evaluation_mode) == 1
    error_message = "evaluation_modes should default to exactly one entry."
  }

  assert {
    condition     = length(aws_config_config_rule.resource.scope) == 0
    error_message = "No scope given should render no scope block."
  }
}

run "scope_renders" {
  command = apply

  variables {
    source_identifier = "REQUIRED_TAGS"
    scope = {
      compliance_resource_types = ["AWS::EC2::Instance"]
      tag_key                   = "Environment"
      tag_value                 = "production"
    }
  }

  assert {
    condition     = length(aws_config_config_rule.resource.scope) == 1
    error_message = "scope given should render exactly one scope block."
  }

  assert {
    condition     = aws_config_config_rule.resource.scope[0].tag_key == "Environment"
    error_message = "scope.tag_key should pass through unchanged."
  }
}

run "proactive_and_detective_evaluation_modes_render_both" {
  command = apply

  variables {
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    evaluation_modes  = ["DETECTIVE", "PROACTIVE"]
  }

  assert {
    condition     = length(aws_config_config_rule.resource.evaluation_mode) == 2
    error_message = "Two evaluation_modes entries should render exactly two evaluation_mode blocks."
  }
}

run "input_parameters_pass_through" {
  command = apply

  variables {
    source_identifier = "REQUIRED_TAGS"
    input_parameters  = jsonencode({ tag1Key = "Environment" })
  }

  assert {
    condition     = jsondecode(aws_config_config_rule.resource.input_parameters).tag1Key == "Environment"
    error_message = "input_parameters should pass through unchanged."
  }
}

run "maximum_execution_frequency_passes_through" {
  command = plan

  variables {
    source_identifier           = "IAM_ROOT_ACCESS_KEY_CHECK"
    maximum_execution_frequency = "TwentyFour_Hours"
  }

  assert {
    condition     = aws_config_config_rule.resource.maximum_execution_frequency == "TwentyFour_Hours"
    error_message = "maximum_execution_frequency should pass through unchanged."
  }
}

run "readme_managed_rule_example" {
  command = plan

  variables {
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

run "readme_scoped_rule_example" {
  command = plan

  variables {
    source_identifier = "REQUIRED_TAGS"
    input_parameters  = jsonencode({ tag1Key = "Environment" })
    scope = {
      compliance_resource_types = ["AWS::EC2::Instance"]
    }
  }
}
