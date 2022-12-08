# !/bin/bash
sudo docker volume create caddy_data
mkdir -p /home/ec2-user/grafana
mkdir -p /home/ec2-user/grafana/datasources
cat <<EOF > /home/ec2-user/grafana/Caddyfile
grafana.malcak.me

reverse_proxy 127.0.0.1:3000
EOF
cat <<EOF > /home/ec2-user/grafana/datasources/prometheus-ds.yml
datasources:
  - name: Prometheus Stage
    type: prometheus
    access: proxy
    url: http://stage.prometheus.malcak.me:9090
    editable: true
  - name: Prometheus Production
    isDefault: true
    type: prometheus
    access: proxy
    url: http://prod.prometheus.malcak.me:9090
    editable: true
EOF
cat <<EOF > /home/ec2-user/grafana/docker-compose.yml
services:
  grafana:
    container_name: grafana
    image: grafana/grafana:9.3.1
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - /home/ec2-user/grafana/datasources:/etc/grafana/provisioning/datasources
      - grafana-data:/var/lib/grafana

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
      - /home/ec2-user/grafana/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
    external: true
  caddy_config:
  grafana-data:
EOF
sudo docker compose -f /home/ec2-user/grafana/docker-compose.yml up -d