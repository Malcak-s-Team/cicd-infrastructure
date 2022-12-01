# !/bin/bash
sudo docker run --rm --volumes-from jenkins -v $(pwd):/backup busybox tar -czvf /backup/backup.tar.gz /var/jenkins_home
mkdir jenkins-backup
mv backup.tar.gz jenkins-backup