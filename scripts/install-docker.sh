# !/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo systemctl enable docker --now
sudo usermod -aG docker ec2-user