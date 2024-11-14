resource "aws_vpc_security_group_ingress_rule" "web_ui" {
  security_group_id = aws_security_group.xui_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "SSH from everywhere"
  from_port   = 7391
  to_port     = 7391
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "vless" {
  security_group_id = aws_security_group.xui_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  description = "vLess"
  from_port   = 59773
  to_port     = 59773
  ip_protocol = "tcp"
}
