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

data "aws_vpc" "sec_vpc" {
  tags = {
    Name = "sec-vpc"
  }
}

data "aws_route_table" "sec_vpc_route_table" {
  vpc_id = data.aws_vpc.sec_vpc.id

  tags = {
    Name = "sec-vpc-route-table"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = data.aws_vpc.sec_vpc.id
  cidr_block              = "42.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "OpenVPN public subnet"
  }
}

resource "aws_route_table_association" "rtba_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = data.aws_route_table.sec_vpc_route_table.id
}

