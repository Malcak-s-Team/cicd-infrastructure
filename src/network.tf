resource "aws_vpc" "cicd" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" : "cicd-vpc"
  }
}

resource "aws_internet_gateway" "cicd" {
  vpc_id = aws_vpc.cicd.id

  tags = {
    "Name" : "cicd-igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.cicd.main_route_table_id
  gateway_id             = aws_internet_gateway.cicd.id
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
