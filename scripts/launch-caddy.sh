# !/bin/bash
sudo docker volume create caddy_data
mkdir -p /home/ec2-user/caddy
cat <<EOF > /home/ec2-user/caddy/Caddyfile
jenkins.malcak.me

reverse_proxy 127.0.0.1:8080
EOF
cat <<EOF > /home/ec2-user/caddy/docker-compose.yml
services:
  caddy:
    container_name: caddy
    image: caddy:2.6.2-alpine
    restart: unless-stopped
    network_mode: "host"
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - /home/ec2-user/caddy/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
    external: true
  caddy_config:
EOF
sudo docker compose -f /home/ec2-user/caddy/docker-compose.yml up -d