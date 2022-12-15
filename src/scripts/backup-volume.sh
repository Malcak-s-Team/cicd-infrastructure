# !/bin/bash
sudo docker run --rm --volumes-from jenkins -v $(pwd):/backup busybox tar -czf /backup/backup-$(date +%F).tar.gz /var/jenkins_home
mkdir $(pwd)/jenkins-backup
mv $(pwd)/backup-*.tar.gz $(pwd)/jenkins-backup