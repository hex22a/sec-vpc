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

resource "aws_instance" "openvpn" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.openvpn_sg.id]
  associate_public_ip_address = true

  user_data = file("startup.sh")

  user_data_replace_on_change = true
  tags = {
    Name = "OpenVPN"
  }
}

resource "aws_security_group" "openvpn_sg" {
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
  security_group_id = aws_security_group.openvpn_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "HTTPS from everywhere"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https_943" {
  security_group_id = aws_security_group.openvpn_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "HTTPS from everywhere"
  from_port   = 943
  to_port     = 943
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.openvpn_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "SSH from everywhere"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "tcp" {
  security_group_id = aws_security_group.openvpn_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "TCP from everywhere"
  from_port   = 1199
  to_port     = 1199
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "udp" {
  security_group_id = aws_security_group.openvpn_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "UDP from everywhere"
  from_port   = 1194
  to_port     = 1194
  ip_protocol = "udp"
}
