terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  # backend "s3" {
  #   bucket         = "ci-terraform-state"
  #   key            = "global/s3/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "ci-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region
}

# module "backend" {
#   source  = "./modules/tf-backend"
#   project = var.project
# }

resource "aws_vpc" "cicd_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  # assign_generated_ipv6_cidr_block = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "publicsubnet" {
  # count                   = length(var.public_subnet_cidr)
  cidr_block              = cidrsubnet(aws_vpc.cicd_vpc.cidr_block, 8, 2)
  vpc_id                  = aws_vpc.cicd_vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
}

resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.cicd_vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.cicd_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internetgateway.id
}

resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.cicd_vpc.id

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

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "jenkins" {
  key_name   = "jenkins"
  public_key = file("./keys/jenkins.pub")
}

resource "aws_instance" "jenkins_instance" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.jenkins.key_name
  subnet_id              = aws_subnet.publicsubnet.id
  vpc_security_group_ids = aws_security_group.jenkins_sg.*.id

  provisioner "file" {
    source      = "./scripts/docker-compose.yml"
    destination = "/home/ec2-user/docker-compose.yml"

    connection {
      type        = "ssh"
      host        = aws_instance.jenkins_instance.public_ip
      user        = "ec2-user"
      private_key = file("./keys/jenkins")
      insecure    = true
    }
  }

  user_data = file("scripts/install-docker.sh")
}

resource "aws_instance" "jenkins_worker" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.jenkins.key_name
  subnet_id              = aws_subnet.publicsubnet.id
  vpc_security_group_ids = aws_security_group.jenkins_sg.*.id

  user_data = file("scripts/worker.sh")
}
