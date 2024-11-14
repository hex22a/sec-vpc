terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65"
    }
  }

  required_version = ">= 1.4.6"


  backend "s3" {}
}

provider "aws" {
  profile = "default"
  region  = var.db_remote_state_region
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

resource "aws_route_table_association" "rtba_public" {
  subnet_id      = aws_subnet.xui_public.id
  route_table_id = data.aws_route_table.sec_vpc_route_table.id
}


