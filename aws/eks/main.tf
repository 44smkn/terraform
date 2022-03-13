terraform {
  backend "s3" {
    region = "ap-northeast-1"
    bucket = "v1-44smkn-terraform-state"
    key    = "aws/eks/v1/terraform.tfstate"
  }

  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
}

provider "aws" {
  region      = local.region
  max_retries = 3
}

module "eks" {
  source       = "github.com/44smkn/terraform//modules/eks-with-karpenter?ref=module_modules_eks-with-karpenter_v0.3.1"
  cluster_name = "44smkn-test"
}

resource "aws_ecr_repository" "karpenter_controller" {
  name                 = "karpenter/controller"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
