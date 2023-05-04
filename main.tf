terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65"
    }
  }

  required_version = ">= 1.4.6"

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

    resource "aws_subnet" "public_1" {
      vpc_id                  = aws_vpc.sec_vpc.id
      cidr_block              = "42.0.0.0/24"
      map_public_ip_on_launch = true
      availability_zone       = "us-east-1a"

      tags = {
        "Name" = "Public subnet 1"
      }
    }

    resource "aws_subnet" "public_2" {
      vpc_id                  = aws_vpc.sec_vpc.id
      cidr_block              = "42.0.1.0/24"
      map_public_ip_on_launch = true
      availability_zone       = "us-east-1b"

      tags = {
        "Name" = "Public subnet 2"
      }
    }

    resource "aws_nat_gateway" "nat_gateway" {
      subnet_id         = aws_subnet.public_1.id
      allocation_id     = aws_eip.nat_ip.id
      connectivity_type = "public"

      tags = {
        "Name" = "Nat gateway"
      }
    }

    resource "aws_eip" "nat_ip" {
      vpc = true
    }

    resource "aws_route_table" "routing_table_public" {
      vpc_id = aws_vpc.sec_vpc.id

      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
      }
    }

    resource "aws_route_table" "routing_table_private" {
      vpc_id = aws_vpc.sec_vpc.id

      route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
      }
    }

    resource "aws_subnet" "private_1" {
      vpc_id                  = aws_vpc.sec_vpc.id
      cidr_block              = "42.0.2.0/24"
      map_public_ip_on_launch = false
      availability_zone       = "us-east-1a"

      tags = {
        "Name" = "Subnet private 1"
      }
    }

    resource "aws_subnet" "private_2" {
      vpc_id                  = aws_vpc.sec_vpc.id
      cidr_block              = "42.0.3.0/24"
      map_public_ip_on_launch = false
      availability_zone       = "us-east-1b"

      tags = {
        "Name" = "Subnet private 2"
      }
    }

    resource "aws_route_table_association" "rtba_public_1" {
      subnet_id      = aws_subnet.public_1.id
      route_table_id = aws_route_table.routing_table_public.id
    }

    resource "aws_route_table_association" "rtba_public_2" {
      subnet_id      = aws_subnet.public_2.id
      route_table_id = aws_route_table.routing_table_public.id
    }

    resource "aws_route_table_association" "rtba_private_1" {
      subnet_id      = aws_subnet.private_1.id
      route_table_id = aws_route_table.routing_table_private.id
    }

    resource "aws_route_table_association" "rtba_private_2" {
      subnet_id      = aws_subnet.private_2.id
      route_table_id = aws_route_table.routing_table_private.id
    }

    resource "aws_security_group" "load_balancer_sg" {
      vpc_id = aws_vpc.sec_vpc.id
      ingress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTPS from everywhere"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
      }
      egress {
        cidr_blocks = ["0.0.0.0/0"]
        description = "all to everywhere"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
      }
    }

    resource "aws_ecs_cluster" "ge_cluster" {
      name = "ge_cluster"

      setting {
        name  = "containerInsights"
        value = "disabled"
      }
    }

    resource "aws_ecs_cluster_capacity_providers" "ge_cluster" {
      cluster_name = aws_ecs_cluster.ge_cluster.name

      capacity_providers = ["FARGATE"]

      default_capacity_provider_strategy {
        capacity_provider = "FARGATE"
      }
    }

    resource "aws_iam_role" "ecs_task_execution_role" {
      name               = "task_role"
      assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
      {
          "Sid": "",
          "Effect": "Allow",
          "Principal": {
              "Service": "ecs-tasks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
      }
  ]
}
EOF
    }

    resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
      role       = aws_iam_role.ecs_task_execution_role.name
      policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    }
  }
}