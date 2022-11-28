echo "estoy aca" > /home/ec2-user/grettings.txt
yum update -y
yum install -y docker
service docker start
service docker enable
usermod -a -G docker ec2-user
newgrp docker

docker compose -f /home/ec2-user/docker-compose.yml up -d
