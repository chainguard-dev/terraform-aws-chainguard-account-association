// This configures a Chainguard environment's OIDC issuer as an Identity
// Provider (IdP), and allows the list of audiences specified via AUDIENCE.
resource "aws_iam_openid_connect_provider" "chainguard_idp" {
  url            = "https://issuer.${var.environment}"
  client_id_list = ["amazon"]

  # AWS wants the thumbprint of the root certificate that was used as our CA.
  # This is not easily scripted, so hard-coding this seems preferable.  Follow
  # the AWS documentation for producing thumbprint if this does not work.
  thumbprint_list = [
    # GlobalSign root certificate (Google Managed Certficates)
    "08745487e891c19e3078c1f2a07e452950ef36f6"
  ]
}
