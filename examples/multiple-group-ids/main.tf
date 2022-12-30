terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    chainguard = {
      # NB: This provider is currently not public
      source = "chainguard/chainguard"
    }
  }
}

provider "chainguard" {
  console_api = "https://console-api.chainguard.dev"
}

provider "aws" {}

resource "chainguard_group" "root" {
  name        = "demo root"
  description = "root group for demo"
}

module "account_association" {
  source = "./../../"

  enforce_domain_name = "chainguard.dev"
  enforce_group_ids   = [chainguard_group.root.id, "0000000000000"]
}

data "aws_caller_identity" "current" {}

resource "chainguard_account_associations" "demo-chainguard-dev-binding" {
  group = chainguard_group.root.id
  amazon {
    account = data.aws_caller_identity.current.account_id
  }
}
