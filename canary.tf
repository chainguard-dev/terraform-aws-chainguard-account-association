resource "aws_iam_role" "canary_role" {
  // Canary role has no permissions, but is used to validate that AWS account
  // connection has been correctly set up.
  name = "chainguard-canary"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "Federated" : aws_iam_openid_connect_provider.chainguard_idp.arn
      },
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Condition" : {
        "StringEquals" : {
          // This role may only be impersonated by Chainguard's "canary"
          // component, which mints tokens suitable for testing.  We are
          // authorizing components nested under GROUP to perform this
          // impersonation.
          "issuer.${var.environment}:sub" : [for id in var.group_ids : "canary:${id}"]
          // Tokens must be intended for use with Amazon.
          "issuer.${var.environment}:aud" : "amazon"
        }
      }
    }]
  })
}
