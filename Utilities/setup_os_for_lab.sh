#!/bin/bash
##@@@@
## Scrip thiet lap co ban cho moi truong lab CentOS 7
## Cach thuc hien 
### yum install wget -y
### wget https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/setup_os_for_lab.sh
### chmod +x setup_os_for_lab.sh
### bash setup_os_for_lab.sh
##@@@@

echo "Thuc hien update OS, vo hieu hoa firewald, cai cac goi can thiet"
sleep 3

yum update -y 
yum install-y epel-release
yum update -y
yum install -y wget byobu vim git 
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo "I.AM.OK"
