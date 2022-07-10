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
}

resource "aws_key_pair" "laptop" {
  key_name   = "44smkn-laptop"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCigWIwCDN7ME+WVisrQzZVEvjfRPkhkMSdJjnz0a4SvaCvbCVPXJ/xZpqAtmnT8gir0s+MaAdyAYEmqbnoI/m30vuINRQ9w8tFUSjuw/9fQO2wZHpoS+PvPpM1XnOeGpLLf3zmjVOvyPOooO9ufs+W+0bZPb2emhaViUqflMsqQ8a2O2gc7jH1bktAeb7/KwUCMJAs/m6/07kNgQ/fJ3LaJF2w7vg1KQq831gZxR6mbBJIttuctymqJcUGwxBRWTxi19GgQdz4og+DjaKBsdjaBn1UYs0YB304iImULXouWo6caK1+i7eohS1vPIWVJ6iCSN8Qs51ofGIC22+1iSwo/GBiePHiBnqM9JcC0wBDCKqJdxTnLc12eU2T2djd/weYmkQOzJ7AeDufHToEF/fV8GzZcveQosBtTamat2UmhzhpKHUdtMOaDpXq3cchmdx0f7wE7u/YuAgEny64LgF4zmqo25OEh+cYRcbUFi0w5ny1j5jqwiPHtlpFLKLAO4jQWfNFRPVLcgEUhMSzkNh3O6dfRnKByUsj4AU+3ajuyehoncrtKZyziPEQfmbAbMmHBar0KiXvVw1m++3F2AcsaYBZ4HvRlQ2uS2HjvtiMs5si+sU8jC8jF+dLp6wDNsw2z7vaJ1sm1bUmLJa3gQFVA29c0/EazKdcVgFxfakAHw== jrywm121@gmail.com"
}

resource "aws_security_group" "private_isu" {
  name        = "allow-ssh-http"
  description = "private-isu"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 1323
    to_port          = 1323
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 9091
    to_port          = 9091
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
