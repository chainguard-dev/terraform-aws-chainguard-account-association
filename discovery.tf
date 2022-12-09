resource "aws_iam_role" "discovery_role" {
  name = "chainguard-discovery"
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
          // This role may only be impersonated by Chainguard's "discovery"
          // components, which mints tokens suitable for talking to EKS
          // clusters.  We are authorizing components nested under GROUP
          // to perform this impersonation.
          "issuer.${var.enforce_domain_name}:sub" : "discovery:${var.enforce_group_id}"
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}

// The permissions to grant the "discovery" role.
resource "aws_iam_role_policy_attachment" "discovery_cluster_viewer" {
  role       = aws_iam_role.discovery_role.name
  policy_arn = aws_iam_policy.eks_read_policy.arn
}
