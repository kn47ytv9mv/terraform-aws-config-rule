# terraform-aws-config-rule

Terraform module for an AWS Config rule — an AWS managed compliance
check, evaluated against the resource inventory
[`terraform-aws-config-recorder`](https://github.com/kn47ytv9mv/terraform-aws-config-recorder)
maintains.

## Cost

AWS Config bills per rule evaluation, separately from the recorder's
own per-configuration-item charge. `maximum_execution_frequency` and
`evaluation_modes` both affect how often a rule evaluates, and
therefore what it bills — a rule left on its default detective,
change-triggered evaluation only bills when something it watches
actually changes. See AWS's
[Config pricing](https://aws.amazon.com/config/pricing/) page for
current rates.

## Design

This module only supports AWS managed rules (`source_identifier` names
one from AWS's own catalog, e.g. `'S3_BUCKET_PUBLIC_READ_PROHIBITED'`)
— not a custom rule backed by a Lambda function or a Guard policy
document. A custom rule needs real supporting infrastructure (the
Lambda function itself, or a policy document) this module does not
create, and covers a materially more advanced use case than "check my
resources against a rule AWS already wrote and maintains." Reach for
the raw resource directly if a genuinely custom rule is needed.

Split from
[`terraform-aws-config-recorder`](https://github.com/kn47ytv9mv/terraform-aws-config-recorder)
because a recorder is 1:1 per account/region, while rules are many —
an account commonly runs dozens of Config rules against one recorder,
each independently created, scoped, and torn down.

## Usage

```hcl
module "no_public_buckets" {
  source = "kn47ytv9mv/config-rule/aws"

  source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
}
```

Or directly from this repository, a parameterized rule scoped to
tagged production instances:

```hcl
module "required_tags" {
  source = "github.com/kn47ytv9mv/terraform-aws-config-rule"

  source_identifier = "REQUIRED_TAGS"
  input_parameters  = jsonencode({ tag1Key = "Environment" })

  scope = {
    compliance_resource_types = ["AWS::EC2::Instance"]
    tag_key                   = "Environment"
    tag_value                 = "production"
  }
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | Name of the rule. If null, a unique name is generated. | `null` | no |
| description | A description of the rule. | `null` | no |
| source_identifier | Identifier of the rule's logic — for an AWS managed rule, its name (e.g. 'S3_BUCKET_PUBLIC_READ_PROHIBITED', 'IAM_ROOT_ACCESS_KEY_CHECK'). See AWS's list of managed rules for the full catalog. | `null` | no |
| input_parameters | JSON object of parameters the rule's logic accepts, for a managed rule that takes any (most do not). If null, the rule uses its own defaults. | `null` | no |
| maximum_execution_frequency | How often a periodic rule re-evaluates, independent of configuration changes (e.g. 'TwentyFour_Hours'). Only meaningful for a rule that supports periodic triggering; ignored otherwise. If null, AWS's own default applies. | `null` | no |
| scope | Narrows which resources the rule evaluates. At most one of compliance_resource_id (a single resource) or compliance_resource_types (a list of resource types) is typically set, optionally combined with tag_key/tag_value to further narrow by tag. If null, the rule evaluates every resource type its source_identifier applies to. | `null` | no |
| evaluation_modes | When the rule evaluates: 'DETECTIVE' (after a resource is created or changed, the classic behavior) and/or 'PROACTIVE' (before creation, against a CloudFormation template — needs a rule that actually supports proactive evaluation). Defaults to detective-only, the mode every rule supports. | `["DETECTIVE"]` | no |
| tags | A map of tags to assign to the rule. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID of the rule. |
| arn | The ARN of the rule. |
| rule_id | AWS's own internal ID for the rule, distinct from its name. |
| name | The name of the rule. |

## License

MIT — see [LICENSE.md](LICENSE.md).
