resource "aws_iam_role" "cosigned_role" {
  name = "chainguard-cosigned"

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
          "issuer.${var.ENV}:sub" : "cosigned:${var.GROUP}"
          // Tokens must be intended for use with Amazon.
          "issuer.${var.ENV}:aud" : "amazon"
        }
      }
    }]
  })
  depends_on = [aws_iam_openid_connect_provider.chainguard_idp]
}

// The permissions to grant the "cosigned" role.
resource "aws_iam_role_policy_attachment" "cosigned_ecr_read" {
  role       = aws_iam_role.cosigned_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  depends_on = [aws_iam_role.cosigned_role]
}

resource "aws_iam_role_policy_attachment" "cosigned_kms_pki_read" {
  role = aws_iam_role.cosigned_role.name
  // TODO: Is there a better policy for what we need?
  policy_arn = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  depends_on = [aws_iam_role.cosigned_role]
}

