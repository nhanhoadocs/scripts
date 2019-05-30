#!/bin/bash -ex
## Date: 26.09.2018
## Cai dat check_mk tai nhan Hoa

##### Khai bao bien o day, sua lai neu ban thay doi

read -p "Nhap IP cua may chu check_MK: " IP_CHECK_MK_SERVER

##### Bat dau thuc hien script
echo "######################################"
echo "Tai dat cac goi"
echo "######################################"
sleep 3

sudo yum install -y xinetd
sudo systemctl start xinetd
sudo systemctl enable xinetd

# wget http://$IP_CHECK_MK_SERVER/managed/check_mk/agents/check-mk-agent-1.5.0p2-1.noarch.rpm

## Duong dan danh cho check_mk managed
https://ms.cloud365.vn/managed/check_mk/agents/check-mk-agent-1.5.0p16-1.noarch.rpm

sudo rpm -ivh check-mk-agent-*

echo "######################################"
echo "Cau hinh cho xinetd"
echo "######################################"
sleep 3
cp /etc/xinetd.d/check_mk /etc/xinetd.d/check_mk.orig
sed -i "s/#only_from      = 127.0.0.1 10.0.20.1 10.0.20.2/only_from     = $IP_CHECK_MK_SERVER/g" /etc/xinetd.d/check_mk

sudo systemctl restart xinetd

echo "######################################"
echo "Tai inventory"
echo "######################################"
sleep 3

# wget -O /usr/lib/check_mk_agent/local/mk_inventory  http://$IP_CHECK_MK_SERVER/admin/check_mk/agents/plugins/mk_inventory.linux
# chmod +x /usr/lib/check_mk_agent/local/mk_inventory  

echo "Hoan tat"