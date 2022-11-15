output "agentless_role_arn" {
  value = {
    for k, v in aws_iam_role.agentless_role : k => v.arn
  }
  description = <<-EOF
    This defines a role without permissions in IAM, but which should be authorized
    to manage clusters via:
     eksctl create iamidentitymapping --cluster  <clusterName> --region=<region> \
          --arn << agenless_role_arn >> \
          --group system:masters --username admin
  EOF
}
