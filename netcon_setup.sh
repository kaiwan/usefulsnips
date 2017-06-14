#!/bin/bash
# netcon_setup.sh
# 
# Quick Description:
# Netconsole setup helper script.
# To be run on the local "patient" system; the remote system is the "doctor"
# / host :)
# Assumes the 'netconsole' kernel module is present.

# Last Updated :
# Created      : 14June2017
# 
# Author:
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# 
# License: MIT.
# 
name=$(basename $0)
#source ./common.sh || {
# echo "${name}: fatal: could not source common.sh , aborting..."
# exit 1
#}

########### Functions follow #######################

remotePort=6666   # default recv port for netconsole

main()
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
 rmmod netconsole || {
   echo "${name}: rmmod netconsole [old instance] failing, aborting..."
   exit 1
 }
}

cmdstr="modprobe netconsole netconsole=+@${localIP}/${localDev},${remotePort}@${remoteIP}/"
echo "Running: ${cmdstr}"
eval ${cmdstr} || {
 echo "${name}: modprobe netconsole ... failed, aborting.."
 exit 1
}

lsmod|grep netconsole
echo "${name}: netconsole locked & loaded.
Ensure (remote) receiver is setup to receive log packets (over nc)"
} # end main()

##### execution starts here #####

[ $(id -u) -ne 0 ] && {
  echo "${name}: requires root."
  exit 1
}
[ $# -ne 1 ] && {
 echo "Usage: ${name} remoteIP"
 exit 1
}
remoteIP=$1
main
exit 0
