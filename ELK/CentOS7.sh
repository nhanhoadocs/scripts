#!/bin/bash
#Hardening limits.conf
cat > /etc/security/limits.conf << EOF
#Change core dump
*  hard    core            0
#Increase max number file
*  -       nofile          65536
EOF
#END Hardening limits.conf

#Hardening sysctl
#Tuning Performance sysctl
cat > /etc/sysctl.conf << EOF
vm.max_map_count = 131072
vm.max_map_count = 131072
# Controls IP packet forwarding
net.ipv4.ip_forward = 0

# Controls source route verification
net.ipv4.conf.default.rp_filter = 1

# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0

# Controls the System Request debugging functionality of the kernel
kernel.sysrq = 0

# Controls whether core dumps will append the PID to the core filename.
# Useful for debugging multi-threaded applications.
kernel.core_uses_pid = 1

# Controls the use of TCP syncookies
net.ipv4.tcp_syncookies = 1

# Disable netfilter on bridges.
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0

# Controls the default maxmimum size of a mesage queue
kernel.msgmnb = 65536

# Controls the maximum size of a message, in bytes
kernel.msgmax = 65536

# Controls the maximum shared segment size, in bytes
kernel.shmmax = 68719476736

# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 4294967296

# Disable IPV6
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.all.disable_ipv6=1

# Enable TCP SYN Cookie Protection
kernel.sem=500 512000 64 2048
fs.file-max=380140

net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.rmem_default=16777216
net.core.wmem_default=16777216

net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 87380 16777216

net.ipv4.ip_local_port_range=1024 65535
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_sack=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_fin_timeout=30

net.ipv4.tcp_keepalive_intvl=30
net.ipv4.tcp_keepalive_probes=5

net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_max_tw_buckets=5000

net.ipv4.tcp_syncookies=1
net.ipv4.tcp_max_orphans=262144
net.ipv4.tcp_max_syn_backlog=8192
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2

net.ipv4.conf.all.accept_source_route=0
net.ipv4.conf.default.accept_source_route=0

net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

net.ipv4.conf.all.arp_filter=1
net.ipv4.conf.default.arp_filter=1

net.ipv4.conf.all.accept_redirects=0
net.ipv4.conf.default.accept_redirects=0

net.ipv4.icmp_echo_ignore_broadcasts=1
net.ipv4.conf.all.accept_redirects=0
net.ipv4.icmp_ignore_bogus_error_responses=1

net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_mem  = 134217728 134217728 134217728
net.ipv4.tcp_rmem = 4096 277750 134217728
net.ipv4.tcp_wmem = 4096 277750 134217728
net.core.netdev_max_backlog = 300000

vm.dirty_background_ratio = 0
vm.dirty_background_bytes = 209715200
vm.dirty_ratio = 40
vm.dirty_bytes = 0
vm.dirty_writeback_centisecs = 100
vm.dirty_expire_centisecs = 200

#Hardening Security sysctl
#Prevent SYN attack
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_max_syn_backlog = 10240

# Disables packet forwarding
net.ipv4.ip_forward = 0
net.ipv4.conf.all.forwarding = 0
net.ipv4.conf.default.forwarding = 0

# Disables IP source routing
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Enable IP spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable ICMP Redirect
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Log Spoofed Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Enable ignoring broadcasts request
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Enable bad error message Protection
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Allowed local port range
net.ipv4.ip_local_port_range = 2000    65535

EOF
#END Hardening sysctl

#Hardening rsyslog
yum -y install rsyslog
systemctl enable rsyslog.service
systemctl start rsyslog.service

# cmd log env

echo "export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug \"[\$(echo \$SSH_CLIENT | cut -d\" \" -f1)] # \$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'" >> ~/.bashrc_profile

touch cmdlog.log

path_rsyslog=/etc/rsyslog.conf
echo '$ModLoad imuxsock'>$path_rsyslog
echo '$ModLoad imklog'>>$path_rsyslog
echo '$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat'>>$path_rsyslog
echo '$FileOwner root'>>$path_rsyslog
echo '$FileGroup adm'>>$path_rsyslog
echo '$FileCreateMode 0640'>>$path_rsyslog
echo '$DirCreateMode 0755'>>$path_rsyslog
echo '$Umask 0022'>>$path_rsyslog

cat >> /etc/rsyslog.conf << EOF
auth,authpriv.*		-/var/log/auth.log
daemon.*			-/var/log/daemon.log
kern.*				-/var/log/kern.log
cron.*				-/var/log/cron.log
user.*				-/var/log/user.log
mail.*				-/var/log/mail.log
local7.*			-/var/log/boot.log
local6.*            -/var/log/cmdlog.log
*.*					-/var/log/messages
EOF
#END Hardening rsyslog

#Hardening Logrotate
cat > /etc/logrotate.d/syslog << EOF
/var/log/cron.log
/var/log/auth.log
/var/log/daemon.log
/var/log/maillog
/var/log/kern.log
/var/log/user.log
/var/log/mail.log
/var/log/boot.log
/var/log/debug.log
/var/log/messages
/var/log/unused.log
/var/log/cmdlog.log
{
    rotate 30
    daily
    missingok
    compress
    delaycompress
    sharedscripts
    postrotate
        /etc/init.d/rsyslog restart
    endscript
}
EOF

source ~/.bashrc_profile
systemctl restart rsyslog

#END Hardening Logrotate


