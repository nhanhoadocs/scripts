#!/bin/bash
#Hardening rsyslog
yum -y install rsyslog
systemctl enable rsyslog.service
systemctl start rsyslog.service

# cmd log env

echo "export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug \"[\$(echo \$SSH_CLIENT | cut -d\" \" -f1)] # \$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'" >> ~/.bashrc_profile

touch /var/log/cmdlog.log

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
auth,authpriv.*         -/var/log/auth.log
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

#END Hardening Logrotate