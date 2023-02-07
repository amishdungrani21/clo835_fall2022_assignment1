provider "aws" {
  region = "us-east-1"
}


# VPC 
data "aws_vpc" "main" {
  default = true
}

data "aws_availability_zones" "available" {
  /*cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = merge(
  local.default_tags, {
  Name = "${local.name_prefix}-vpc"*/
  state = "available"
}


# Data source
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  prefix_main  = "${local.prefix}-${var.env}"
}
module "globalvars" {
  source = "/home/ec2-user/environment/clo835_fall2022_assignment1/terraform/modules/globalvars"
}


resource "aws_instance" "workflow" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type                   = lookup(var.type, var.env)
  key_name               = aws_key_pair.amishkey.key_name
  vpc_security_group_ids = [aws_security_group.workflow_security_group.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.prefix_main}-workflow"
    }
  )
}


resource "aws_key_pair" "amishkey" {
  key_name   = local.prefix_main
  public_key = file("${local.prefix_main}.pub")
}


resource "aws_security_group" "workflow_security_group" {
  name        = "allow_ssh"
  description = "Allow HTTP and SSH inbound traffic"

  ingress {
    description      = "SSH from everyone"
    from_port        = 22
    to_port          = 22
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


  ingress {
    description      = "HTTP from blue"
    from_port        = 8081
    to_port          = 8081
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP from pink"
    from_port        = 8082
    to_port          = 8082
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP from lime"
    from_port        = 8083
    to_port          = 8083
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.prefix_main}-workflow_security_group"
    }
  )
}

resource "aws_ecr_repository" "webrepo" {
  name = "web_repo"

}

resource "aws_ecr_repository" "sqlrepo" {
  name = "sql_repos"

}