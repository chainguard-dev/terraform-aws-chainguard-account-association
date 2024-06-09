terraform {
  required_providers {
    chainguard = {
      source = "chainguard-dev/chainguard"
    }
  }
}

resource "chainguard_group" "root" {
  name        = "demo root"
  description = "root group for demo"
}

data "aws_caller_identity" "current" {}

module "aws-impersonation" {
  source = "./../../"

  account   = data.aws_caller_identity.current.account_id
  group_ids = [chainguard_group.root.id]
}

resource "chainguard_account_associations" "demo-chainguard-dev-binding" {
  name  = "example"
  group = chainguard_group.root.id
  amazon {
    account = data.aws_caller_identity.current.account_id
  }
}
