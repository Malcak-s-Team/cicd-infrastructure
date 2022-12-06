resource "aws_vpc" "cicd" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" : "cicd-vpc"
  }
}

resource "aws_internet_gateway" "gateway_cicd" {
  vpc_id = aws_vpc.cicd.id

  tags = {
    "Name" : "cicd-ig"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.cicd.main_route_table_id
  gateway_id             = aws_internet_gateway.gateway_cicd.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.cicd.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = cidrsubnet(aws_vpc.cicd.cidr_block, 8, 2)
  map_public_ip_on_launch = true

  tags = {
    "Name" : "cicd-public-subnet"
  }
}

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
}
