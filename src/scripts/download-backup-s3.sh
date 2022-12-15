#!/bin/bash
sudo /usr/local/bin/aws s3 cp s3://${bucket}/${backup_revision} ${workpath}/backup.tar.gz

if [[ -f "${workpath}/backup.tar.gz" ]]; then
  docker run --rm -v ${workpath}:/backup busybox tar -xzf /backup/backup.tar.gz -C /backup/
  mv ${workpath}/var/jenkins_home ${workpath}/jenkins-volume
  rm -rf ${workpath}/var ${workpath}/backup.tar.gz
else
  mkdir -p ${workpath}/jenkins-volume
fi
