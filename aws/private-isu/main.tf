module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = "private-isu"
  cidr                 = "172.16.0.0/16"
  azs                  = ["ap-northeast-1d"]
  public_subnets       = ["172.16.10.0/24"]
  private_subnets      = ["172.16.11.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "private-isu"
  }
}

resource "aws_eip" "private_isu" {
  instance   = aws_instance.private_isu.id
  vpc        = true
  depends_on = [module.vpc]
}

resource "aws_instance" "private_isu" {
  ami                    = local.ami
  instance_type          = "c6g.large"
  key_name               = aws_key_pair.laptop.key_name
  vpc_security_group_ids = [aws_security_group.private_isu.id]
  subnet_id              = element(module.vpc.public_subnets, 0)
  iam_instance_profile   = aws_iam_role.ssm_role.name
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
  }
}

resource "aws_key_pair" "laptop" {
  key_name   = "44smkn-laptop"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCigWIwCDN7ME+WVisrQzZVEvjfRPkhkMSdJjnz0a4SvaCvbCVPXJ/xZpqAtmnT8gir0s+MaAdyAYEmqbnoI/m30vuINRQ9w8tFUSjuw/9fQO2wZHpoS+PvPpM1XnOeGpLLf3zmjVOvyPOooO9ufs+W+0bZPb2emhaViUqflMsqQ8a2O2gc7jH1bktAeb7/KwUCMJAs/m6/07kNgQ/fJ3LaJF2w7vg1KQq831gZxR6mbBJIttuctymqJcUGwxBRWTxi19GgQdz4og+DjaKBsdjaBn1UYs0YB304iImULXouWo6caK1+i7eohS1vPIWVJ6iCSN8Qs51ofGIC22+1iSwo/GBiePHiBnqM9JcC0wBDCKqJdxTnLc12eU2T2djd/weYmkQOzJ7AeDufHToEF/fV8GzZcveQosBtTamat2UmhzhpKHUdtMOaDpXq3cchmdx0f7wE7u/YuAgEny64LgF4zmqo25OEh+cYRcbUFi0w5ny1j5jqwiPHtlpFLKLAO4jQWfNFRPVLcgEUhMSzkNh3O6dfRnKByUsj4AU+3ajuyehoncrtKZyziPEQfmbAbMmHBar0KiXvVw1m++3F2AcsaYBZ4HvRlQ2uS2HjvtiMs5si+sU8jC8jF+dLp6wDNsw2z7vaJ1sm1bUmLJa3gQFVA29c0/EazKdcVgFxfakAHw== jrywm121@gmail.com"
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group" "private_isu" {
  name        = "allow-ssh-http"
  description = "private-isu"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["126.78.9.238/32"]
  }
  egress {
    description      = "ALLOW ALL"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "aws_iam_policy_document" "ssm_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ssm_role" {
  name = "ec2-role-for-ssm"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
  name               = "ec2-role-for-ssm"
  assume_role_policy = data.aws_iam_policy_document.ssm_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_role" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
