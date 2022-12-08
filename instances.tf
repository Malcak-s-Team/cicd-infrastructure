resource "aws_key_pair" "cicd" {
  key_name   = "cicd"
  public_key = file("./keys/cicd.pub")
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.cicd.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = aws_security_group.cicd.*.id

  root_block_device {
    volume_size = 30
    tags = {
      "Name" = "Automation Node Disk"
    }
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./keys/cicd")
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "export AWS_ACCESS_KEY_ID=${var.aws_access_key_id}",
      "export AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}",
      "export AWS_DEFAULT_REGION=${var.region}",
      "export BACKUP_REVISION=${var.jenkins_backup_revision}",
      "export S3_BUCKET=malcak-jenkins-state",
      "sudo yum install git -y",
      "sudo yum install unzip -y",
      "chmod u+x -R /home/ec2-user/scripts",
      "mkdir -p /home/ec2-user/jenkins",
      "/home/ec2-user/scripts/install-docker-compose.sh",
      "/home/ec2-user/scripts/install-awscli.sh",
      "/home/ec2-user/scripts/download-s3.sh",
      "/home/ec2-user/scripts/launch-jenkins.sh",
      "/home/ec2-user/scripts/launch-caddy.sh",
    ]
  }

  tags = {
    "Name" = "Automation Node"
  }
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.cicd.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = aws_security_group.cicd.*.id

  root_block_device {
    volume_size = 30
    tags = {
      "Name" = "Worker Node Disk"
    }
  }


  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./keys/cicd")
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "sudo yum install unzip -y",
      "chmod u+x -R /home/ec2-user/scripts",
      "/home/ec2-user/scripts/install-docker-compose.sh",
      "/home/ec2-user/scripts/install-jdk11.sh",
      "/home/ec2-user/scripts/install-awscli.sh",
      "/home/ec2-user/scripts/install-terraform.sh",
      "mkdir /home/ec2-user/jenkins",
    ]
  }

  tags = {
    "Name" : "Worker Node"
  }
}

resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.cicd.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = aws_security_group.cicd.*.id

  root_block_device {
    volume_size = 30
    tags = {
      "Name" = "Sonarqube Node Disk"
    }
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./keys/cicd")
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x -R /home/ec2-user/scripts",
      "/home/ec2-user/scripts/install-docker-compose.sh",
      "/home/ec2-user/scripts/launch-sonarqube.sh",
      "/home/ec2-user/scripts/launch-caddy-sonar.sh",
    ]
  }

  tags = {
    "Name" = "Sonarqube Node"
  }
}

resource "aws_instance" "grafana" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.cicd.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = aws_security_group.cicd.*.id

  root_block_device {
    volume_size = 30
    tags = {
      "Name" = "Grafana Node Disk"
    }
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./keys/cicd")
  }

  provisioner "file" {
    source      = "./scripts"
    destination = "/home/ec2-user/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod u+x -R /home/ec2-user/scripts",
      "/home/ec2-user/scripts/install-docker-compose.sh",
      "/home/ec2-user/scripts/launch-grafana.sh",
    ]
  }

  tags = {
    "Name" = "Grafana Node"
  }
}
