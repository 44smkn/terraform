terraform {
  backend "s3" {
    region = "ap-northeast-1"
    bucket = "v1-44smkn-terraform-state"
    key    = "%%TARGET%%/v1/terraform.tfstate"
  }

  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19.0"
    }
  }
}

provider "aws" {
  region      = local.region
  max_retries = 3
}
