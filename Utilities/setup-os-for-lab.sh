#!/bin/bash
##@@@@
## Scrip thiet lap co ban cho moi truong lab CentOS 7
## Cach thuc hien 
### yum install wget -y
### wget https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/install-docker.sh
### chmod +x install-docker.sh
### bash install-docker.sh
##@@@@

yum update -y 
yum install epel-release
yum update -y
yum install wget byobu vim git 
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
