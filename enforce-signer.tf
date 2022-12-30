data "aws_caller_identity" "current" {}

resource "aws_iam_role" "enforce_signer_role" {
  name = "chainguard-enforce-signer"

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
          // This role may only be impersonated by Chainguard's "enforce-signer"
          // component, which mints tokens suitable for encrypting and decrypting keys.
          // We are authorizing components nested under GROUP to perform this
          // impersonation.
          "issuer.${var.enforce_domain_name}:sub" : [for id in local.enforce_group_ids : "signer:${id}"]
          // Tokens must be intended for use with Amazon.
          "issuer.${var.enforce_domain_name}:aud" : "amazon"
        }
      }
    }]
  })
}

// Our enforce signer role needs encrypt/decrypt/re-encrypt with KMS.
// This policy is based on this sample:
// https://docs.aws.amazon.com/eks/latest/userguide/security_iam_id-based-policy-examples.html#policy_example2
resource "aws_iam_policy" "enforce_signer_policy" {
  name        = "chainguard-signer-policy"
  description = "A policy to allow Chainguard to Encrypt|Decrypt|Reencrypt using KMS."
  policy      = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*"
          ],
          "Resource": "*"
        }
      ]
    }
  EOF
}

// The permissions to grant the "enforce_signer" role.
resource "aws_iam_role_policy_attachment" "enforce_signer_kms_keys" {
  role       = aws_iam_role.enforce_signer_role.name
  policy_arn = aws_iam_policy.enforce_signer_policy.arn
}
