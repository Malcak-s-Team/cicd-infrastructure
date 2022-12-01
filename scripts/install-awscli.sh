# !/bin/bash
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install
sudo rm -rf awscliv2.zip
sudo rm -rf ./aws
mkdir -p /home/ec2-user/.aws
touch /home/ec2-user/.aws/credentials
cat <<EOF > /home/ec2-user/.aws/credentials
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY}
EOF
sudo chmod 0600 /home/ec2-user/.aws/credentials
sudo chown root:root /home/ec2-user/.aws/credentials