locals {
  github_owner = "44smkn"
}

terraform {
  required_version = ">= 1.0"
  backend "s3" {
    region = "ap-northeast-1"
    bucket = "v1-44smkn-terraform-state"
    key    = "%%TARGET%%/v1/terraform.tfstate"
  }
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  owner = local.github_owner
}
