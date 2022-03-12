locals {
  repo_name      = "44smkn/terraform"
  s3_bucket_name = "v1-44smkn-terraform-state"
  region         = "ap-northeast-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = local.region
}

# OIDC

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
  client_id_list  = ["sts.amazonaws.com"]
}

# IAM Roles

module "aws" {
  source = "github.com/suzuki-shunsuke/terraform-aws-tfaction?ref=v0.1.2"

  name        = "github"
  main_branch = "main"

  repo                               = local.repo_name
  s3_bucket_tfmigrate_history_name   = local.s3_bucket_name
  s3_bucket_terraform_plan_file_name = local.s3_bucket_name
  s3_bucket_terraform_state_name     = local.s3_bucket_name
}

resource "aws_iam_role_policy_attachment" "terraform_plan_readonly" {
  role       = module.aws.aws_iam_role_terraform_plan_name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_apply_admin" {
  role       = module.aws.aws_iam_role_terraform_apply_name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# S3 Buckets

# tfaction requires three types of S3 buckets.
# * Remote Backend
# * Terraform Plan File
# * tfmigrate History File
# In this getting started, we use the same bucket for them.
resource "aws_s3_bucket" "tfaction" {
  bucket        = local.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "tfaction" {
  bucket = aws_s3_bucket.tfaction.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "tfaction" {
  bucket = aws_s3_bucket.tfaction.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
