# Configure Chainguard service access.

Terraform module to connect Chainguard to your AWS account.

This module is needed to leverage certain service integrations from
[Chainguard](https://www.chainguard.dev).

## Usage
This module binds a Chainguard IAM group to a AWS account.

```terraform
module "chainguard-account-association" {
  source = "chainguard-dev/chainguard-account-association/aws"

  group_ids = [var.group_id]
  account   = var.account
}

resource "chainguard_account_associations" "example" {
  name  = "example"
  group = var.group_id

  amazon {
    account = var.account
  }
}
```

## How does it work?

Chainguard has an OIDC identity provider. This module configures your AWS
acccount to recognize that OIDC identity provider and allows certain tokens
to bind to certain IAM roles.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.chainguard_idp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.canary_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.catalog-syncer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.catalog-syncer-ecr-push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account"></a> [account](#input\_account) | The AWS account ID to which we are binding the Chainguard groups. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Domain of the Chainguard environment | `string` | `"enforce.dev"` | no |
| <a name="input_group_ids"></a> [group\_ids](#input\_group\_ids) | Chainguard IAM group IDs to bind your AWS account to. | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
