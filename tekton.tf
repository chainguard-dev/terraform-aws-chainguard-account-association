resource "aws_iam_role" "tekton_pipelines_role" {
  name = "chainguard-tekton-pipelines"
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
          // This role may only be impersonated by Chainguard's
          // "tekton-pipelines" component, which mints tokens suitable for
          // reading images from ECR. We are authorizing components nested
          // under this group id to perform this impersonation.
          "issuer.${var.enforce_domain_name}:sub" : "tekton-pipelines:${var.enforce_group_id}"
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "tekton_pipelines_ecr_read" {
  role       = aws_iam_role.tekton_pipelines_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role" "tekton_chains_role" {
  name = "chainguard-tekton-chains"
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
          // This role may only be impersonated by Chainguard's "tekton-chains"
          // component, which mints tokens suitable for writing attestations to ECR.
          // We are authorizing components nested under GROUP to perform this
          // impersonation.
          "issuer.${var.enforce_domain_name}:sub" : "tekton-chains:${var.enforce_group_id}"
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "tekton_chains_ecr_read" {
  role = aws_iam_role.tekton_chains_role.name
  // AmazonEC2ContainerRegistryPowerUser is the role needed to write images.
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
