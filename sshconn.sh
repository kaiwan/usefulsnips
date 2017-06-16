#!/bin/bash
# sshconn.sh
# 
# Quick Description:
# Simple wrapper over ssh
# 
# Last Updated :
# Created      : 15June2017
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
[ $# -lt 2 ] && {
  echo "Usage: ${name} hostname username [IP-addr-to-ssh-to]"
  exit 1
}

########### Functions follow #######################

SUBNET="192.168.0.*"  # !! _Assumption_ !!
TMPFILE=./.tmp

# Params:
# $1 : username
# $2 : IP address
do_connect()
{
local cmdstr="ssh ${1}@${2}"
echo "Running: ${cmdstr}"
eval "${cmdstr}" || {
  echo "${name}: ssh failed, aborting ..."
  exit 3
}
}

main()
{
echo "Scanning hosts on subnet \"${SUBNET}\" ... patience pl ..."
nmap -sn ${SUBNET} >${TMPFILE}
rec=$(grep -i "^Nmap scan report for.*${host}" ${TMPFILE} |head -n1)
  # !! if >1 match, we only take the first match !!
#echo "rec=${rec}"
[ -z "${rec}" ] && {
  echo "${name}: No hostname \"${host}\" found, aborting ..."
  echo "TIP: try running this script as root."
  rm -f ${TMPFILE}
  exit 2
}

# found match w/ user-supplied hostname
qhost=$(echo "${rec}"|awk '{print $5}')  # q = 'qualified'
# subsequent awk'ing (latter 2) are get rid of the parantheses : (ip-addr)
qIP=$(echo "${rec}"|awk '{print $6}'|awk -F')' '{print $1}'|awk -F'(' '{print $2}')

rm -f ${TMPFILE}
do_connect ${user} ${qIP}

} # end main()

##### execution starts here #####

host=$1
user=$2
if [ $# -eq 3 ]; then  # shortcut!
  do_connect $2 $3
else
  main
fi
echo "${name}: done."
exit 0
