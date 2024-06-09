resource "aws_iam_role" "catalog-syncer" {
  name = "chainguard-catalog-syncer"

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
          // This role may only be impersonated by Chainguard's "catalog-syncer"
          // component, which mints tokens suitable for publishing images to ECR.
          // We are authorizing components nested under GROUP to perform this
          // impersonation.
          "issuer.${var.environment}:sub" : [for id in var.group_ids : "catalog-syncer:${id}"]
          // Tokens must be intended for use with Amazon.
          "issuer.${var.environment}:aud" : "amazon"
        }
      }
    }]
  })
}

// The permissions to grant the "catalog-syncer" role.
resource "aws_iam_role_policy_attachment" "catalog-syncer-ecr-push" {
  role       = aws_iam_role.catalog-syncer.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
