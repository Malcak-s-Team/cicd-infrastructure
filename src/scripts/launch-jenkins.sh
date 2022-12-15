# !/bin/bash
cat <<EOF > ${workpath}/docker-compose.yml
services:
  jenkins:
    container_name: jenkins
    image: jenkins/jenkins:2.379-centos7
    restart: on-failure
    privileged: true
    user: root
    ports:
      - 8080:8080
      - 50000:50000
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
      - "${workpath}/jenkins-volume:/var/jenkins_home"
EOF
docker compose -f ${workpath}/docker-compose.yml up -d