#!/bin/bash

## Ngày: 11.04.2019
## Script cài đặt collector-sidecar cho các node compute đối với Graylog 2.5
## Cách thực hiện
## R&D - Clou365 - Nhân Hòa.

read -p "Graylog Server IP Address: " IP_GRAYLOG_SERVER
read -p "Graylog Server IP Address: " IP_GRAYLOG_CLIENT
echo "Tai cac goi bo tro va bo cai cua collector-sidecar"
sleep 3



yum install wget -y
wget https://github.com/Graylog2/collector-sidecar/releases/download/0.1.8/collector-sidecar-0.1.8-1.x86_64.rpm
rpm -i collector-sidecar-0.1.8-1.x86_64.rpm

cp /etc/graylog/collector-sidecar/collector_sidecar.yml /etc/graylog/collector-sidecar/collector_sidecar.yml.bka

cat << EOF > /etc/graylog/collector-sidecar/collector_sidecar.yml
server_url: http://$IP_GRAYLOG_SERVER:9000/api/
update_interval: 10
tls_skip_verify: false
send_status: true
list_log_files:
    - /var/log
node_id: $IP_GRAYLOG_CLIENT
collector_id: file:/etc/graylog/collector-sidecar/collector-id
cache_path: /var/cache/graylog/collector-sidecar
log_path: /var/log/graylog/collector-sidecar
log_rotation_time: 86400
log_max_age: 604800
tags:
    - linux
    - computenode
backends:
    - name: nxlog
      enabled: false
      binary_path: /usr/bin/nxlog
      configuration_path: /etc/graylog/collector-sidecar/generated/nxlog.conf
    - name: filebeat
      enabled: true
      binary_path: /usr/bin/filebeat
      configuration_path: /etc/graylog/collector-sidecar/generated/filebeat.yml
EOF


