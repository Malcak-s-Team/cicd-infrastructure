output "jenkins_state" {
  value = module.jenkins_state.bucket
}

output "jenkins_instance_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}

output "sonarqube_instance_public_ip" {
  value = aws_instance.sonarqube.public_ip
}
