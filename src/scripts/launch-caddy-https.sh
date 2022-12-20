# !/bin/bash
docker volume create caddy_data
mkdir -p ${path}/caddy
cat <<EOF > ${path}/caddy/Caddyfile
${subdomain}.malcak.me

reverse_proxy https://127.0.0.1:${port} {
  transport http {
    tls_insecure_skip_verify
  }
}
EOF
cat <<EOF > ${path}/caddy/docker-compose.yml
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
      - ${path}/caddy/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
    external: true
  caddy_config:
EOF
docker compose -f ${path}/caddy/docker-compose.yml up -d