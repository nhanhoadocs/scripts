#!/bin/bash
# Create Swap
# CanhDX NhanHoa Cloud Team 

size=$1
if [ $# -eq 0 ]
  then
    echo "Missing Swap size"
    echo "Example: curl -Lso- https://raw.githubusercontent.com/uncelvel/scripts/master/Utilities/create_swap.sh 2 | bash"
    exit
fi

function sw_u {
    fallocate -l "$size"G /swapfile
    #sudo dd if=/dev/zero of=/swapfile count=2048 bs=1MiB
    ls -lh /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    swapon --show
    sleep 3
    cp /etc/{fstab,fstab.bk}
    echo "/swapfile   swap    swap    sw  0   0" >> /etc/fstab
    free -m
    echo "DONE"
}

function sw_c {
    # Tao swapfile
    fallocate -l "$size"G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    swapon --show
    sleep 3
    # Chinh sua de luu cau hinh khi reboot
    cp /etc/{fstab,fstab.bk}
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    # echo "vm.swappiness=10" >> /etc/sysctl.conf
    # echo "vm.vfs_cache_pressure = 50" >> /etc/sysctl.conf
    # sysctl -p
    free -m
    echo "DONE"
}

if free | awk '/^Swap:/ {exit !$2}'; then
    echo "Swap exists"
else
    if [ -f /etc/lsb-release ]; then
        echo "Ubuntu"
        sw_u
    else [ -f /etc/redhat-release ]
        echo "CentOS"
        sw_c
    fi
fi
echo "DONE"