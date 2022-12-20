resource "aws_security_group" "cicd" {
  vpc_id = aws_vpc.cicd.id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "cicd-security-group"
  }
}

resource "aws_security_group" "vault" {
  vpc_id = aws_vpc.cicd.id

  ingress {
    from_port       = 8200
    to_port         = 8201
    protocol        = "tcp"
    security_groups = [aws_security_group.cicd.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" : "vault-security-group"
  }
}
