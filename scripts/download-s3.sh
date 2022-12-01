#!/bin/bash
aws s3 cp s3://malcak-jenkins-state/backup.tar.gz /home/ec2-user/
sudo docker run --rm -v /home/ec2-user/:/backup busybox tar -xzvf /backup/backup.tar.gz -C /backup/
sudo mv /home/ec2-user/var/jenkins_home /home/ec2-user/jenkins-volume
sudo rm -rf /home/ec2-user/var /home/ec2-user/backup.tar.gz