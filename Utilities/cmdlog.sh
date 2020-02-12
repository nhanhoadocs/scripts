#!/bin/bash
# CMD log
# CanhDX NhanHoa Cloud Team 

echo "Install rsyslog"
yum -y install rsyslog || apt-get -y install rsyslog 
systemctl enable rsyslog.service || chkconfig rsyslog on
systemctl start rsyslog.service || service rsyslog start

echo "Config log History"
touch ~/.bash_profile
cp ~/{.bash_profile,.bash_profile.bk}
echo "export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug \"[\$(echo \$SSH_CLIENT | cut -d\" \" -f1)] # \$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'" >> ~/.bash_profile
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile
touch /var/log/cmdlog.log

echo "Config rsyslog"
mv /etc/rsyslog.{conf,conf.bk}
cat >> /etc/rsyslog.conf << EOF
\$ModLoad imuxsock
\$ModLoad imklog
\$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
\$FileOwner root
\$FileGroup adm
\$FileCreateMode 0640
\$DirCreateMode 0755
\$Umask 0022
auth,authpriv.*-/var/log/auth.log
daemon.*-/var/log/daemon.log
kern.*-/var/log/kern.log
cron.*-/var/log/cron.log
user.*-/var/log/user.log
mail.*-/var/log/mail.log
local7.*-/var/log/boot.log
local6.*-/var/log/cmdlog.log
EOF

echo "Restart rsyslog"
systemctl restart  rsyslog.service || service rsyslog restart
source ~/.bash_profile

echo "DONE - Please logout and login"
