terraform {
  required_providers {
    chainguard = {
      source = "chainguard-dev/chainguard"
    }
  }
}

resource "chainguard_group" "root1" {
  name        = "demo root 1"
  description = "root group 1 for demo"
}

resource "chainguard_group" "root2" {
  name        = "demo root 2"
  description = "root group 2 for demo"
}

data "aws_caller_identity" "current" {}

module "aws-impersonation" {
  source = "./../../"

  account   = data.aws_caller_identity.current.account_id
  group_ids = [
    chainguard_group.root1.id,
    chainguard_group.root2.id,
  ]
}

resource "chainguard_account_associations" "demo1-chainguard-dev-binding" {
  name  = "example"
  group = chainguard_group.root1.id
  amazon {
    account = data.aws_caller_identity.current.account_id
  }
}

resource "chainguard_account_associations" "demo2-chainguard-dev-binding" {
  name  = "example"
  group = chainguard_group.root2.id
  amazon {
    account = data.aws_caller_identity.current.account_id
  }
}
