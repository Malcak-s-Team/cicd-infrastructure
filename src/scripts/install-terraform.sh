# !/bin/bash
yum install -y yum-utils
curl -SL "https://releases.hashicorp.com/terraform/1.3.5/terraform_1.3.5_linux_amd64.zip" \
  -o "/tmp/terraform_1.3.5_linux_amd64.zip"
unzip /tmp/terraform_1.3.5_linux_amd64.zip -d /usr/local/bin
rm -rf /tmp/terraform_1.3.5_linux_amd64.zip