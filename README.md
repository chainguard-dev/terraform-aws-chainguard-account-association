# Terraform AWS Enforce Module

Terraform module to connect Chainguard Enforce to your AWS Account

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.22.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.chainguard_idp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.eks_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agentless_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.canary_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.cosigned_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tekton_chains_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.tekton_pipelines_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.agentless_eks_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cosigned_ecr_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cosigned_kms_pki_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tekton_chains_ecr_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.tekton_pipelines_ecr_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_enforce_domain_name"></a> [enforce\_domain\_name](#input\_enforce\_domain\_name) | Domain name of your Chainguard Enforce environment | `string` | `"guak.dev"` | no |
| <a name="input_enforce_group_id"></a> [enforce\_group\_id](#input\_enforce\_group\_id) | Enforce IAM group ID to bind your AWS account to | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agentless_role_arn"></a> [agentless\_role\_arn](#output\_agentless\_role\_arn) | This defines a role without permissions in IAM, but which should be authorized<br>to manage clusters via:<br> eksctl create iamidentitymapping --cluster  <clusterName> --region=<region> \<br>      --arn << agenless\_role\_arn >> \<br>      --group system:masters --username admin |
<!-- END_TF_DOCS -->