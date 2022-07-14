module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                 = "isucon11-qualify"
  cidr                 = "172.16.0.0/16"
  azs                  = ["ap-northeast-1d"]
  public_subnets       = ["172.16.10.0/24"]
  private_subnets      = ["172.16.11.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "isucon11-qualify"
  }
}

resource "aws_eip" "isucon11_qualify" {
  instance   = aws_instance.isucon11_qualify.id
  vpc        = true
  depends_on = [module.vpc]
}

resource "aws_instance" "isucon11_qualify" {
  ami                    = local.ami
  instance_type          = "c6i.large"
  vpc_security_group_ids = [aws_security_group.isucon11_qualify.id]
  subnet_id              = element(module.vpc.public_subnets, 0)
  iam_instance_profile   = aws_iam_role.ssm_role.name
  root_block_device {
    encrypted = true
  }
  metadata_options {
    http_tokens = "required"
  }
}

#tfsec:ignore:aws-vpc-no-public-egress-sgr
resource "aws_security_group" "isucon11_qualify" {
  name        = "allow-ssh-http"
  description = "isucon11-qualify"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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
