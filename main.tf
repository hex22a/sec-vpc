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
    "Name" = "sec-vpc-internet-gateway"
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.sec_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "sec-vpc-route-table"
  }
}

