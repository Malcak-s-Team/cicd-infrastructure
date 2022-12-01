# !/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo systemctl enable docker --now
