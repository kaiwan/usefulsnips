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
#[ $# -ne 1 ] && {
#  echo "Usage: ${name} "
#  exit 1
#}

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
fg_cyan ; date ; color_reset
#echo

# Distribution Info
secho "Linux Distributor:"
lsb_release -a 2>/dev/null
#echo

secho "Uptime:"
w|head -n1
#echo

secho "Kernel: "
uname -r
cat /proc/version
#echo

secho "Toolchain/compiler: "
gcc --version|head -n1
#echo

secho "CPU:"
grep "model name" /proc/cpuinfo |uniq |cut -d: -f2
cpu_cores=$(getconf -a|grep _NPROCESSORS_ONLN|awk '{print $2}')
grep -w -q "lm" /proc/cpuinfo && echo " 64-bit"
egrep -w -q "vmx|smx" /proc/cpuinfo || echo " -no h/w virt support available-"
grep -w -q "vmx" /proc/cpuinfo && echo " Intel VT-x (h/w virtualization support available)" || echo " -no h/w virt support-"
grep -w -q "smx" /proc/cpuinfo && echo " AMD SMX (h/w virtualization support available)"
echo " cpu cores: ${cpu_cores}"
#echo

secho "RAM:"
free -h
#echo

secho "IP address(es): " ; hostname -I
#echo

secho "Battery: "
acpi 2>/dev/null
} > ${OUTFILE}

start()
{
ShowTitle " System Info"
gather_sys

cat ${OUTFILE}
rm -f ${OUTFILE}
}

##### 'main' : execution starts here #####

start
exit 0
