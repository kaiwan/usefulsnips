#!/bin/bash
# sshconn.sh
# 
# Quick Description:
# Simple wrapper over ssh.
# 
# Last Updated : 30Dec2019
# Created      : 15Jun2017
# 
# (c) Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# License: MIT
name=$(basename $0)
[ $# -lt 2 ] && {
  echo "Usage: ${name} [hostname] username [IP-addr-to-ssh-to]
Specify either as:
  ${name} <hostname> <username>
            -OR- 
  ${name} - <username> <IP-address>"
  exit 1
}

########### Functions follow #######################

SUBNET="192.168.0.*"  # !! _Assumption_ !!
SUBNET3="192.168.0"   # !! _Assumption_ !!
TMPFILE=./.tmp

# Params:
# $1 : username
# $2 : IP address
do_connect()
{
local errfile=/tmp/err.$$
# disable stict checking
local sshopts="-o UserKnownHostsFile=/dev/null"  #"-v"
local cmdstr="ssh ${sshopts} ${1}@${2}"

echo "${cmdstr}"
eval "${cmdstr}" 2>${errfile} || {
  echo "${name}: ssh failed"
  #exit 3
  local cmd2=$(grep "ssh-keygen " ${errfile})
  [ -z "${cmd2}" ] && exit 3   # it failed for some other reason...

  cmd3=$(sed 's/^[[:space:]]*//' <<< "${cmd2}")
  cmd3="${cmd3} -N ''"
  echo "cmd3 = ${cmd3}"
  eval "${cmd3}" && {
    echo "*** Ran shh-keygen, now re-attempting to ssh..."
	eval "${cmdstr}" || exit 4  # 'should' succeed!
  }
}
rm -f ${errfile}
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
  #echo "ip = $3"
  # Is it a full-fledged IP addr? look for the 3 dots '.' using awk :-)
  fullip=$(echo $3|awk '/.*\..*\..*\./ {print $0}')
  if [ ! -z "${fullip}" ] ; then
    ipaddr=$3
  else
    ipaddr=${SUBNET3}.$3
  fi
  do_connect $2 ${ipaddr}
else
  main
fi
echo "${name}: done."
exit 0
