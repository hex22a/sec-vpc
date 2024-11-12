terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65"
    }
  }

  required_version = ">= 1.4.6"


  backend "s3" {
    region = "us-east-1"
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "sec_vpc" {
  cidr_block           = "42.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.sec_vpc.id

  tags = {
    "Name" = "Internet gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.sec_vpc.id
  cidr_block              = "42.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "Public subnet 1"
  }
}

resource "aws_route_table" "routing_table_public" {
  vpc_id = aws_vpc.sec_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "rtba_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.routing_table_public.id
}

resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.sec_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "all to everywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_443" {
  security_group_id = aws_security_group.instance_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "HTTPS from everywhere"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https_943" {
  security_group_id = aws_security_group.instance_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "HTTPS from everywhere"
  from_port   = 943
  to_port     = 943
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.instance_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "SSH from everywhere"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "tcp" {
  security_group_id = aws_security_group.instance_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "TCP from everywhere"
  from_port   = 1199
  to_port     = 1199
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "udp" {
  security_group_id = aws_security_group.instance_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "UDP from everywhere"
  from_port   = 1194
  to_port     = 1194
  ip_protocol = "udp"
}
