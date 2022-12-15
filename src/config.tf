data "template_cloudinit_config" "jenkins_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.tpl"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/init.tpl", {
      workdir = "jenkins"
    })
  }

  part {
    filename     = "install-docker-compose.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-docker-compose.sh")
  }

  part {
    filename     = "install-awscli.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-awscli.sh")
  }

  part {
    filename     = "kdownload-backup-s3.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/download-backup-s3.sh", {
      bucket          = "${module.jenkins_state.bucket}"
      backup_revision = "${var.jenkins_backup_revision}"
      workpath        = "/home/ec2-user/jenkins"
    })


  }

  part {
    filename     = "launch-jenkins.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/launch-jenkins.sh", {
      workpath = "/home/ec2-user/jenkins"
    })
  }

  part {
    filename     = "launch-caddy.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/launch-caddy.sh", {
      path      = "/home/ec2-user"
      subdomain = "jenkins"
      port      = "8080"
    })
  }
}

data "template_cloudinit_config" "worker_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.tpl"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/init.tpl", {
      workdir = "worker"
    })
  }

  part {
    filename     = "install-docker-compose.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-docker-compose.sh")
  }

  part {
    filename     = "install-awscli.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-awscli.sh")
  }

  part {
    filename     = "install-terraform.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-terraform.sh")
  }

  part {
    filename     = "install-jdk11.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-jdk11.sh")
  }
}

data "template_cloudinit_config" "sonarqube_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.tpl"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/init.tpl", {
      workdir = "sonar"
    })
  }

  part {
    filename     = "install-docker-compose.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-docker-compose.sh")
  }

  part {
    filename     = "launch-sonarqube.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/launch-sonarqube.sh", {
      workpath = "/home/ec2-user/sonar"
    })
  }

  part {
    filename     = "launch-caddy.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/launch-caddy.sh", {
      path      = "/home/ec2-user"
      subdomain = "sonarqube"
      port      = "9000"
    })
  }
}

data "template_cloudinit_config" "grafana_config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.tpl"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/init.tpl", {
      workdir = "grafana"
    })
  }

  part {
    filename     = "install-docker-compose.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/scripts/install-docker-compose.sh")
  }

  part {
    filename     = "launch-grafana.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/launch-grafana.sh", {
      workpath = "/home/ec2-user/grafana"
    })
  }

  part {
    filename     = "launch-caddy.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/launch-caddy.sh", {
      path      = "/home/ec2-user"
      subdomain = "grafana"
      port      = "3000"
    })
  }
}
