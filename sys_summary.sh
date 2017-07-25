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
source ./common.sh || {
 echo "${name}: fatal: could not source common.sh , aborting..."
 exit 1
}
#[ $# -ne 1 ] && {
#  echo "Usage: ${name} "
#  exit 1
#}

OUTFILE=/tmp/.$$

########### Functions follow #######################


gather_sys()
{
date
echo

# Distribution Info
lsb_release -a 2>/dev/null
echo

echo -n "uptime:" ; w|head -n1
echo

echo -n "Kernel: "
uname -r
cat /proc/version
echo

echo -n "Toolchain/compiler: "
gcc --version|head -n1
echo

echo "CPU:"
grep "model name" /proc/cpuinfo |uniq |cut -d: -f2
cpu_cores=$(getconf -a|grep _NPROCESSORS_ONLN|awk '{print $2}')
grep -w -q "lm" /proc/cpuinfo && echo " 64-bit"
egrep -w -q "vmx|smx" /proc/cpuinfo || echo " -no h/w virt support available-"
grep -w -q "vmx" /proc/cpuinfo && echo " Intel VT-x (h/w virtualization support available)" || echo " -no h/w virt support-"
grep -w -q "smx" /proc/cpuinfo && echo " AMD SMX (h/w virtualization support available)"
echo " cpu cores: ${cpu_cores}"
echo

echo "RAM:"
free -h
echo

echo -n "IP address(es): " ; hostname -I
echo

acpi 2>/dev/null
} > ${OUTFILE}

start()
{
gather_sys
cat ${OUTFILE}
rm -f ${OUTFILE}
}

##### 'main' : execution starts here #####

start
exit 0
