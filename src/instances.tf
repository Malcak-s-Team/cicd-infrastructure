resource "aws_key_pair" "cicd" {
  key_name   = "cicd"
  public_key = file("../keys/cicd.pub")
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.cicd.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = aws_security_group.cicd.*.id
  iam_instance_profile   = aws_iam_instance_profile.jenkins_profile.id

  root_block_device {
    volume_size = 30
    tags = {
      "Name" = "Automation Server Disk"
    }
  }

  user_data_base64 = data.template_cloudinit_config.jenkins_config.rendered

  tags = {
    "Name" = "Automation Server"
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
      "Name" = "Automation Worker Disk"
    }
  }

  user_data_base64 = data.template_cloudinit_config.worker_config.rendered

  tags = {
    "Name" : "Automation Worker"
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
      "Name" = "Sonarqube Server Disk"
    }
  }

  user_data_base64 = data.template_cloudinit_config.sonarqube_config.rendered

  tags = {
    "Name" = "Sonarqube Server"
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
      "Name" = "Grafana Server Disk"
    }
  }

  user_data_base64 = data.template_cloudinit_config.grafana_config.rendered

  tags = {
    "Name" = "Grafana Server"
  }
}

resource "aws_instance" "vault" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.cicd.key_name
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.cicd.id, aws_security_group.vault.id]
  iam_instance_profile   = aws_iam_instance_profile.vault.id

  root_block_device {
    volume_size = 30
    tags = {
      "Name" = "Vault Server Disk"
    }
  }

  user_data_base64 = data.template_cloudinit_config.vault_config.rendered

  tags = {
    "Name" = "Vault Server"
  }

  lifecycle {
    prevent_destroy = true
  }
}
