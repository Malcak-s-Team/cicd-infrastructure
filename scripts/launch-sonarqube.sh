# !/bin/bash
sudo sysctl -w vm.max_map_count=524288
sudo sysctl -w fs.file-max=131072
sudo ulimit -n 131072
sudo ulimit -u 8192
sudo docker volume create --name sonarqube_data
sudo docker volume create --name sonarqube_logs
sudo docker volume create --name sonarqube_extensions
mkdir -p /home/ec2-user/sonar
cat <<EOF > /home/ec2-user/sonar/docker-compose.yml
services:
  sonarqube:
    container_name: sonar
    image: sonarqube:9.7.1-community
    depends_on:
      - db
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://db:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: sonar
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    ports:
      - "9000:9000"
  db:
    image: postgres:12
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data

volumes:
  sonarqube_data:
    external: true
  sonarqube_extensions:
    external: true
  sonarqube_logs:
    external: true
  postgresql:
  postgresql_data:
EOF
sudo docker compose -f /home/ec2-user/sonar/docker-compose.yml up -d