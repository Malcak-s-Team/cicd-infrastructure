output "bucket" {
  value = module.backend.bucket
}

output "dynamodb_table" {
  value = module.backend.dynamodb_table
}

output "jenkins_state" {
  value = module.jenkins_state.bucket
}

output "jenkins_instance_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "sonarqube_instance_public_ip" {
  value = aws_instance.sonarqube.public_ip
}

output "grafana_instance_public_ip" {
  value = aws_instance.grafana.public_ip
}
