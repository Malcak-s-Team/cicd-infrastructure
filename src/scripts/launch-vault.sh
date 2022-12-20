#!/bin/bash
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install vault
cat <<EOF > /etc/vault.d/vault.hcl
ui = true

# storage "file" {
#   path = "/opt/vault/data"
# }

# storage "s3" {
#   bucket = "${storage}"
# }

storage "dynamodb" {
  table = "${storage}"
}

# HTTPS listener
listener "tcp" {
  address       = "127.0.0.1:8200"
  tls_cert_file = "/opt/vault/tls/tls.crt"
  tls_key_file  = "/opt/vault/tls/tls.key"
}
EOF
export VAULT_API_ADDR="https://127.0.0.1:8200"
systemctl daemon-reload
systemctl restart vault
