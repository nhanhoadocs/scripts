#!/bin/bash


# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PLAIN='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${RED}Error:${PLAIN} This script must be run as root!" && exit 1

# install wget, fio and virt-what ioping nc fio 
if  [ ! -e '/usr/bin/wget' ] || [ ! -e '/usr/bin/fio' ] ||  [ ! -e '/usr/sbin/virt-what' ]
then
	echo -e "Please wait..."
	yum clean all > /dev/null 2>&1 && yum install -y epel-release > /dev/null 2>&1 && yum install -y wget fio virt-what fio ioping nc > /dev/null 2>&1 || (  apt-get update > /dev/null 2>&1 && apt-get install -y wget fio virt-what  > /dev/null 2>&1 )
fi

virtua=$(virt-what)

if [[ ${virtua} ]]; then
	virt="$virtua"
else
	virt="No Virt"
fi

get_opsy() {
	[ -f /etc/redhat-release ] && awk '{print ($1,$3~/^[0-9]/?$3:$4)}' /etc/redhat-release && return
	[ -f /etc/os-release ] && awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release && return
	[ -f /etc/lsb-release ] && awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release && return
}

next() {
	printf "%-70s\n" "-" | sed 's/\s/-/g'
}


io_test() {
    (LANG=C dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' | sed 's/^[ \t]*//;s/[ \t]*$//'
}

dd_test() {
	echo "dd Test"
	io1=$( io_test )
	echo "I/O (1st run)        : $io1"
	io2=$( io_test )
	echo "I/O (2nd run)        : $io2"
	io3=$( io_test )
	echo "I/O (3rd run)        : $io3"
	ioraw1=$( echo $io1 | awk 'NR==1 {print $1}' )
	[ "`echo $io1 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw1=$( awk 'BEGIN{print '$ioraw1' * 1024}' )
	ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
	[ "`echo $io2 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw2=$( awk 'BEGIN{print '$ioraw2' * 1024}' )
	ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
	[ "`echo $io3 | awk 'NR==1 {print $2}'`" == "GB/s" ] && ioraw3=$( awk 'BEGIN{print '$ioraw3' * 1024}' )
	ioall=$( awk 'BEGIN{print '$ioraw1' + '$ioraw2' + '$ioraw3'}' )
	ioavg=$( awk 'BEGIN{printf "%.1f", '$ioall' / 3}' )
	echo "Average              : $ioavg MB/s"
}

fio_test() {
	if [ -e '/usr/bin/fio' ]; then
		echo "Fio Test"
		local tmp=$(mktemp)
		fio --randrepeat=1 --ioengine=libaio --direct=1 --gtod_reduce=1 --name=fio_test --filename=fio_test --bs=4k --numjobs=1 --iodepth=64 --size=256M --readwrite=randrw --rwmixread=75 --runtime=30 --time_based --output="$tmp"
		
		if [ $(fio -v | cut -d '.' -f 1) == "fio-2" ]; then
			local iops_read=`grep "iops=" "$tmp" | grep read | awk -F[=,]+ '{print $6}'`
			local iops_write=`grep "iops=" "$tmp" | grep write | awk -F[=,]+ '{print $6}'`
			local bw_read=`grep "bw=" "$tmp" | grep read | awk -F[=,B]+ '{if(match($4, /[0-9]+K$/)) {printf("%.1f", int($4)/1024);} else if(match($4, /[0-9]+M$/)) {printf("%.1f", substr($4, 0, length($4)-1))} else {printf("%.1f", int($4)/1024/1024);}}'`"MB/s"
			local bw_write=`grep "bw=" "$tmp" | grep write | awk -F[=,B]+ '{if(match($4, /[0-9]+K$/)) {printf("%.1f", int($4)/1024);} else if(match($4, /[0-9]+M$/)) {printf("%.1f", substr($4, 0, length($4)-1))} else {printf("%.1f", int($4)/1024/1024);}}'`"MB/s"
			
		elif [ $(fio -v | cut -d '.' -f 1) == "fio-3" ]; then
			local iops_read=`grep "IOPS=" "$tmp" | grep read | awk -F[=,]+ '{print $2}'`
			local iops_write=`grep "IOPS=" "$tmp" | grep write | awk -F[=,]+ '{print $2}'`
			local bw_read=`grep "bw=" "$tmp" | grep READ | awk -F"[()]" '{print $2}'`
			local bw_write=`grep "bw=" "$tmp" | grep WRITE | awk -F"[()]" '{print $2}'`
		fi

		echo "Read performance     : $bw_read"
		echo "Read IOPS            : $iops_read"
		echo "Write performance    : $bw_write"
		echo "Write IOPS           : $iops_write"
		
		rm -f $tmp fio_test
	else
		echo "Fio is missing!!! Please install Fio before running test."
	fi
}

ioping2() {
    if [ -e '/usr/bin/ioping' ]; then
        ioping -c 10 . > ioping.txt && result=$(cat ioping.txt | grep min | cut -d "=" -f2) && echo "Min/Avg/Max/Mdev           : $result" && rm -rf ioping.txt
	fi
}

calc_disk() {
	local total_size=0
	local array=$@
	for size in ${array[@]}
	do
		[ "${size}" == "0" ] && size_t=0 || size_t=`echo ${size:0:${#size}-1}`
		[ "`echo ${size:(-1)}`" == "M" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' / 1024}' )
		[ "`echo ${size:(-1)}`" == "T" ] && size=$( awk 'BEGIN{printf "%.1f", '$size_t' * 1024}' )
		[ "`echo ${size:(-1)}`" == "G" ] && size=${size_t}
		total_size=$( awk 'BEGIN{printf "%.1f", '$total_size' + '$size'}' )
	done
	echo ${total_size}
}

test() {
	cname=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
	freq=$( awk -F: '/cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo | sed 's/^[ \t]*//;s/[ \t]*$//' )
	tram=$( free -m | awk '/Mem/ {print $2}' )
	uram=$( free -m | awk '/Mem/ {print $3}' )
	swap=$( free -m | awk '/Swap/ {print $2}' )
	uswap=$( free -m | awk '/Swap/ {print $3}' )
	up=$( awk '{a=$1/86400;b=($1%86400)/3600;c=($1%3600)/60} {printf("%d days, %d hour %d min\n",a,b,c)}' /proc/uptime )
	load=$( w | head -1 | awk -F'load average:' '{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//' )
	opsy=$( get_opsy )
	arch=$( uname -m )
	lbit=$( getconf LONG_BIT )
	kern=$( uname -r )
	date=$( date )
	disk_size1=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $2}' ))
	disk_size2=($( LANG=C df -hPl | grep -wvE '\-|none|tmpfs|devtmpfs|by-uuid|chroot|Filesystem' | awk '{print $3}' ))
	disk_total_size=$( calc_disk ${disk_size1[@]} )
	disk_used_size=$( calc_disk ${disk_size2[@]} )
	
	#echo "System Info"
	#next
	#echo "CPU model            : $cname"
	#echo "Number of cores      : $cores"
	#echo "CPU frequency        : $freq MHz"
	#echo "Total size of Disk   : $disk_total_size GB ($disk_used_size GB Used)"
	#echo "Total amount of Mem  : $tram MB ($uram MB Used)"
	#echo "Total amount of Swap : $swap MB ($uswap MB Used)"
	#echo "System uptime        : $up"
	#echo "Load average         : $load"
	#echo "OS                   : $opsy"
	#echo "Arch                 : $arch ($lbit Bit)"
	#echo "Kernel               : $kern"
	#echo "Virt                 : $virt"
	#echo "Date                 : $date"
	#echo ""
	echo "Disk Speed"
	echo "-----------------------------------"
	dd_test
	echo "-----------------------------------"
	fio_test $cores
    echo "-----------------------------------"
	echo "Ioping test"
    ioping -c 10 . > ioping.txt && result=$(cat ioping.txt | grep min | cut -d "=" -f2) && echo "Min/Avg/Max/Mdev     : $result" && rm -rf ioping.txt
    echo "-----------------------------------"
}
clear
tmp=$(mktemp)
test | tee $tmp
(echo "curl -Lso- https://raw.githubusercontent.com/uncelvel/tunning/master/scripts/bench_vm.sh | bash" && cat $tmp) > result.log
cat result.log | nc termbin.com 9999
echo "-----------------------------------"
