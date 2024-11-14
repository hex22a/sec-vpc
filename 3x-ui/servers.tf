data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_subnet" "xui_public" {
  vpc_id                  = data.aws_vpc.sec_vpc.id
  cidr_block              = "42.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    "Name" = "Public subnet 3X-UI"
  }
}

resource "aws_security_group" "xui_sg" {
  vpc_id = data.aws_vpc.sec_vpc.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "all to everywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https_443" {
  security_group_id = aws_security_group.xui_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "HTTPS from everywhere"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.xui_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "SSH from everywhere"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_instance" "xui" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.xui_public.id
  vpc_security_group_ids      = [aws_security_group.xui_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "3x-ui"
  }
}
