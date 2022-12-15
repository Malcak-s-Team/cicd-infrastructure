# !/bin/bash
docker volume create caddy_data
mkdir -p ${workpath}/datasources
cat <<EOF > ${workpath}/datasources/prometheus-ds.yml
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
cat <<EOF > ${workpath}/docker-compose.yml
services:
  grafana:
    container_name: grafana
    image: grafana/grafana:9.3.1
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ${workpath}/datasources:/etc/grafana/provisioning/datasources
      - grafana-data:/var/lib/grafana

volumes:
  grafana-data:
EOF
docker compose -f ${workpath}/docker-compose.yml up -d