#!/bin/bash
# monitor.sh
# Part of the Seawolf project.
# Simple script to setup & run various 'monitor' programs in terminal windows.
# Run as : gksu </path/to/>monitor.sh | sudo </path/to/>monitor.sh
# 
# Author: Kaiwan NB
# (c) Kaiwan NB, kaiwanTECH
# MIT License.
#
# Ref:
# http://kaiwantech.wordpress.com/2014/01/06/simple-system-monitoring-for-a-linux-desktop/
#
name=$(basename $0)

usage()
{
  echo "Usage: ${name} [0|1]
 0 => run in CLI mode
 1 => run in GUI mode.

[Explanation for Geeks:
- In CLI (command line / console) mode, one only gets to see the output of dstat
(still quite useful); this is as there's only one terminal window available.
- In GUI mode (when running on X), one will see the output of:
  iotop
  dstat
  dstat [plain]
  iftop
 in separate (pseudo)terminal windows!
]
 "
}

if [ `id -u` -ne 0 ]; then
  echo "$0: need to be root!"
  echo "Run like this (copy-paste onto terminal):
sudo ~/kaiwanTECH/utils/monitor.sh 0|1"
  exit 1
fi

which dstat >/dev/null || {
 echo "${name}: error: dstat not installed?" ; exit 1
}

CLI_MODE=0
pgrep Xorg >/dev/null || CLI_MODE=1
[ $# -eq 1 ] && {
  [ $1 -eq 0 ] && CLI_MODE=1
}

if [ ${CLI_MODE} -eq 1 ] ; then     #------------- CLI Mode
  dstat --time --top-io-adv --top-cpu --top-mem 5
  exit 0
fi

#if [ $1 -ne 1 ] ; then
# usage
# exit 1
#fi

#----------------- GUI Mode
which iotop  >/dev/null || {
 echo "${name}: error: iotop not installed?" ; exit 1
}
which iftop >/dev/null || {
 echo "${name}: error: iftop not installed?" ; exit 1
}

choices=$(zenity --title="kaiwanTECH : Simple Linux Monitoring" --list --text="Select any/all appropriate options" \
		--checklist \
		--column="Select" --column="Monitoring Software" \
		--width=400 --height=250 \
		"1" "iotop" \
		"2" "dtop" \
		"3" "dstat" \
		"4" "iftop" 2>/dev/null)

echo "${choices}"

echo "${choices}" | grep -w iotop >/dev/null 2>&1
[ $? -eq 0 ] && lxterminal --working-directory=${HOME}/ --command="iotop" --title="IOTOP" --geometry=90x10 &

echo "${choices}" | grep -w dtop >/dev/null 2>&1
[ $? -eq 0 ] && lxterminal --working-directory=${HOME}/ --command="dstat --time --top-io-adv --top-cpu --top-mem 5" --title="DTOP" --geometry=110x10 &

echo "${choices}" | grep -w dstat >/dev/null 2>&1
[ $? -eq 0 ] && lxterminal --working-directory=${HOME}/ --command="dstat" --title="DSTAT" --geometry=90x10 &

echo "${choices}" | grep -w iftop >/dev/null 2>&1
[ $? -eq 0 ] && {
   netif=$(ifconfig |grep "^enp"|awk '{print $1}')
   intf=$(zenity --title="Specify net interface" --entry --text="Pl specify Network interface to monitor:" --entry-text="${netif}" 2>/dev/null)
   [ ! -z ${intf} ] && lxterminal --working-directory=${HOME}/ --command="iftop -i ${intf}" --title="IFTOP ${intf}" --geometry=85x15 &
}
