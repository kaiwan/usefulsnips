#!/bin/bash
# sys_summary.sh
# 
# Quick Description:
# Spit out system info..
# 
# Last Updated : 25july2017
# Created      : 25july2017
# 
# Author:
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# 
# License:
# MIT License.
# 
name=$(basename $0)
PFX=$(dirname `which ${name}`)
source ${PFX}/common.sh || {
 echo "${name}: fatal: could not source ./common.sh , aborting..."
 exit 1
}

OUTFILE=/tmp/.$$

########### Functions follow #######################

setcolor() { bg_cyan ; fg_white
}
secho()
{
setcolor ; echo "$@" ; color_reset
}

gather_sys()
{
color_reset
echo "$(date)"  ; color_reset ; echo -n " "

becho "hostnamectl:"
hostnamectl

# Distribution Info
becho "Linux Distributor:"
lsb_release -a |grep "Description" |cut -d: -f2 2>/dev/null

becho "Uptime:"
w|head -n1

becho "Kernel: "
uname -r
cat /proc/version

becho "Toolchain/compiler: "
gcc --version|head -n1

becho "CPU:"
grep "model name" /proc/cpuinfo |uniq |cut -d: -f2
cpu_cores=$(getconf -a|grep _NPROCESSORS_ONLN|awk '{print $2}')
grep -w -q "lm" /proc/cpuinfo && echo -n " 64-bit :"
egrep -w -q "vmx|smx" /proc/cpuinfo || echo -n " -no h/w virt support available- :"
grep -w -q "vmx" /proc/cpuinfo && echo -n " Intel VT-x (h/w virtualization support available) :" || echo -n " -no h/w virt support- :"
grep -w -q "smx" /proc/cpuinfo && echo -n " AMD SMX (h/w virtualization support available) :"
echo " cpu cores: ${cpu_cores}"

becho "RAM:"
free -h

becho "IP address(es): " ; hostname -I

becho "Battery: "
acpi 2>/dev/null
} > ${OUTFILE}

start()
{
ShowTitle "System Info"
gather_sys

cat ${OUTFILE}
rm -f ${OUTFILE}
}

##### 'main' : execution starts here #####

start
exit 0
