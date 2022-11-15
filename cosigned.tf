resource "aws_iam_role" "cosigned_role" {
  for_each = toset(var.enforce_group_ids)

  name = "chainguard-cosigned-${each.value}"

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
          // This role may only be impersonated by Chainguard's "cosigned"
          // component, which mints tokens suitable for reading images from ECR.
          // We are authorizing components nested under GROUP to perform this
          // impersonation.
          "issuer.${var.enforce_domain_name}:sub" : "cosigned:${each.value}"
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}

// The permissions to grant the "cosigned" role.
resource "aws_iam_role_policy_attachment" "cosigned_ecr_read" {
  for_each = aws_iam_role.cosigned_role

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cosigned_kms_pki_read" {
  for_each = aws_iam_role.cosigned_role

  role = each.value.name
  // TODO: Is there a better policy for what we need?
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
}
