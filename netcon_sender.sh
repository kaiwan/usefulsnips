#!/bin/bash
# netcon_sender.sh
# 
# Quick Description:
# Netconsole setup helper script.
# To be run on the local "patient" system; the remote system is the "doctor"
# / host :)
# Assumes the 'netconsole' kernel module is present.
#
# To learn more details and how to etup netconsole, pl read:
# https://www.kernel.org/doc/Documentation/networking/netconsole.txt
# https://wiki.ubuntu.com/Kernel/Netconsole
# https://mraw.org/blog/2010/11/08/Debugging_using_netconsole/
# 
# Last Updated : 18Nov2022
# Created      : 14Jun2017
# 
# Author:
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# 
# License: MIT.
# 
name=$(basename $0)

########### Functions follow #######################

remotePort=6666   # default recv port for netconsole

netcon_host_setup()
{
localIP=$(hostname -I |cut -d" " -f1)
[ -z ${localIP} ] && {
  echo "${name}: error: could not fetch local IP address (network ok?)"
  exit 1
}
localDev=$(ifconfig |grep -B1 "${localIP}" |head -n1 |cut -d":" -f1)
[ -z ${localDev} ] && {
  echo "${name}: error: could not fetch local network interface name (network ok?)"
  exit 1
}
lsmod|grep -q netconsole && {
 sudo rmmod netconsole || {
   echo "${name}: rmmod netconsole [old instance] failing, aborting..."
   exit 1
 }
}

# Ensure console printks are enabled
local last_3=$(awk '{print $2,$3,$4}' /proc/sys/kernel/printk)
sudo sh -c "echo "8 ${last_3}" > /proc/sys/kernel/printk"
local console_level=$(awk '{print $1}' /proc/sys/kernel/printk)
[ ${console_level} -ne 8 ] && {
   echo "${name}: couldn't set console loglevel to 8? Aborting..."
   exit 1
}

#modprobe netconsole netconsole=+@${localIP}/${localDev},${remotePort}@${remoteIP}/
# + => 'extended' console support (verbose)
local cmdstr="sudo modprobe netconsole netconsole=@${localIP}/${localDev},${remotePort}@${remoteIP}/"
echo "Running: ${cmdstr}"
eval ${cmdstr} || {
 echo "${name}: sudo modprobe netconsole ... failed, aborting..
*** NOTE- netconsole can fail on a WiFi sender device, pl Ensure ***
*** you use Wired Ethernet on this (sender) system               ***
 Kernel log - last 20 lines - follows:
"
 sudo dmesg |tail -n20
 exit 1
}

lsmod|grep netconsole
echo "${name}: netconsole locked & loaded.
Ensure (remote) receiver is setup to receive log packets (over nc)
 Res: https://wiki.ubuntu.com/Kernel/Netconsole"
}


##### execution starts here #####
[ $# -ne 1 ] && {
 echo "Usage: ${name} remoteIP"
 exit 1
}
remoteIP=$1
netcon_host_setup
exit 0
