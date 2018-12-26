#!/bin/bash
# Add Smokeping
# CanhDX NhanHoa Cloud Team 

if [ $# -eq 0 ]
  then
    echo "Missing Value"
    echo "Example: curl -Lso- https://raw.githubusercontent.com/uncelvel/scripts/master/Utilities/create_swap.sh 2 | bash"
    exit
fi
if [ "$1" == "" && "$2" == "" ]; then
echo "Mising variable $0 <compute> <ip>"
fi

com=$1
ip=$2

# Echo file 
cat << EOF >> /etc/smokeping/config
++ VM-$com-${ip//.}

 menu = VM-$com-$ip
 title = VM-$com-$ip
 host = $ip
EOF

# Restart Service 
systemctl restart httpd
systemctl restart smokeping

# Done 
echo "DONE"
echo "http://192.168.70.87/?target=VM-random-com.VM-$com-$ip"