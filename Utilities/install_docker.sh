#!/bin/bash
##@@@@
## Scrip cai dat docker, docker-compose tren CentOS 7
## Cach thuc hien 
### yum install wget -y
### wget https://raw.githubusercontent.com/nhanhoadocs/scripts/master/Utilities/install_docker.sh
### chmod +x install_docker.sh
### bash install_docker.sh
##@@@@

echo "Cai dat cac pham mem tien ich"
sleep 3
yum update -y
yum install -y yum-utils device-mapper-persistent-data lvm2 wget
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "Cai dat container"
sleep 3
yum install -y docker-ce docker-ce-cli containerd.io

echo "Khoi dong docker"
sleep 3

systemctl start docker 
systemctl enable docker 

echo "Phien ban docker da cai dat"
docker --version

echo "Cai dat docker-compose"
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

echo "Kiem tra phien ban docker-compose"
sleep 3
docker-compose -v

echo "I.A.OK"