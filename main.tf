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

module "jenkins_state" {
  source = "./modules/s3"
  name   = "malcak-jenkins-state"
}

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
  instance_type          = "t2.small"
  key_name               = aws_key_pair.jenkins.key_name
  subnet_id              = aws_subnet.publicsubnet.id
  vpc_security_group_ids = aws_security_group.jenkins_sg.*.id

  root_block_device {
    volume_size = 16
  }

  tags = {
    "Name" = "Jenkins Master Node"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.jenkins_instance.public_ip
    private_key = file("./keys/jenkins")
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "export AWS_ACCESS_KEY_ID=${var.aws_access_key_id}",
      "export AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}",
      "export AWS_DEFAULT_REGION=${var.region}",
      "export S3_BUCKET=malcak-jenkins-state",
      "sudo yum install git -y",
      "chmod +x -R /home/ec2-user/scripts",
      "/home/ec2-user/scripts/install-docker.sh",
      "/home/ec2-user/scripts/install-docker-compose.sh",
      "/home/ec2-user/scripts/install-awscli.sh",
      "/home/ec2-user/scripts/download-s3.sh",
      "/home/ec2-user/scripts/launch-jenkins.sh",
      "/home/ec2-user/scripts/launch-caddy.sh",
      "sleep 10",
    ]
  }
}

resource "aws_instance" "jenkins_worker" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.jenkins.key_name
  subnet_id              = aws_subnet.publicsubnet.id
  vpc_security_group_ids = aws_security_group.jenkins_sg.*.id

  root_block_device {
    volume_size = 24
  }


  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.jenkins_worker.public_ip
    private_key = file("./keys/jenkins")
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "export AWS_ACCESS_KEY_ID=${var.aws_access_key_id}",
      "export AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}",
      "sudo yum install git -y",
      "chmod +x -R /home/ec2-user/scripts",
      "/home/ec2-user/scripts/install-docker.sh",
      "/home/ec2-user/scripts/install-docker-compose.sh",
      "/home/ec2-user/scripts/install-jdk11.sh",
      "/home/ec2-user/scripts/install-awscli.sh",
      "/home/ec2-user/scripts/install-terraform.sh",
      "mkdir /home/ec2-user/jenkins",
      "sleep 10",
    ]
  }

  tags = {
    "Name" : "Jenkins Worker Node"
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.jenkins.key_name
  subnet_id              = aws_subnet.publicsubnet.id
  vpc_security_group_ids = aws_security_group.jenkins_sg.*.id

  root_block_device {
    volume_size = 16
  }

  tags = {
    "Name" = "Sonarqube Node"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.sonarqube.public_ip
    private_key = file("./keys/jenkins")
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 10",
      "chmod +x -R /home/ec2-user/scripts",
      "/home/ec2-user/scripts/install-docker.sh",
      "/home/ec2-user/scripts/install-docker-compose.sh",
      "/home/ec2-user/scripts/launch-sonarqube.sh",
      "/home/ec2-user/scripts/launch-caddy-sonar.sh",
      "sleep 10",
    ]
  }
}
