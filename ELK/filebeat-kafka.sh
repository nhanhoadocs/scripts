########### File Config ##############

source function.sh

########### Disable IPv6 ##############

cat > /etc/sysctl.conf << EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

sysctl -p

########### Config SSH ##############

echocolor "Config SSH log"

sed -i 's/#SyslogFacility AUTH/SyslogFacility local3/'g /etc/ssh/sshd_config

echo "# Log ssh" >> /etc/rsyslog.conf
echo "local3.*                                                /var/log/ssh" >> /etc/rsyslog.conf

touch /var/log/ssh

systemctl restart sshd
systemctl restart rsyslog

########### Config Log CMD ##############

cat envcmd.txt >> ~/.bash_profile

echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile

source ~/.bash_profile

echo "local6.*                                                /var/log/cmdlog.log" >> /etc/rsyslog.conf
touch /var/log/cmdlog.log
systemctl restart rsyslog


########### Install filebeat ##############

echocolor "Add repo and install filebeat"

sleep 3

cat > /etc/yum.repos.d/elastic.repo << EOF
[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF


yum install filebeat-6.2.4 -y

systemctl start filebeat
systemctl enable filebeat

########### Config filebeat ##############

echocolor "Config filebeat"

cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.yml.orig
rm -rf /etc/filebeat/filebeat.yml
touch /etc/filebeat/filebeat.yml

cat > /etc/filebeat/filebeat.yml << EOF
filebeat:
  prospectors:
    - paths:
        - /var/log/*
      encoding: utf-8
      input_type: log
      fields:
        level: debug
      document_type: type
  registry_file: /var/lib/filebeat/registry
output:
  kafka:
    hosts: ["192.168.70.109:9092"]
    topic: log-nh
logging:
  to_syslog: false
  to_files: true
  files:
    path: /var/log/filebeat
    name: filebeat
    rotateeverybytes: 1048576000 # = 1GB
    keepfiles: 7
  selectors: ["*"]
  level: info
EOF


systemctl stop filebeat
rm -rf /var/lib/filebeat/registry
systemctl start filebeat

########### Finish ##############

echocolor "Finish"

sleep 3
