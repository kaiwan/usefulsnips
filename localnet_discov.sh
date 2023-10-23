#!/bin/bash
# localnet_dicov.sh
# A utility script that - quite usefully - 'discovers' all devices currently
# on the local network domain(s)
# Leverages nmap for all the real work!
#
# (c) kaiwanTECH, 2022
name=$(basename $0)
#--- UPDATE as required-----------------------------------------------------------
PFX=/home/kaiwan/rpi/cam/homesec_cam_via_motion/yocto_work/seccam_git/provisioning
#---------------------------------------------------------------------------------
DEV_DB=${PFX}/dev.csv
VERBOSE=0  # keep to 0 for device provisioning
DEBUG=0

# Params:
#  $1 : network domain to scan (f.e. 10.20.1.0)
discover_devices_local()
{
#local tmpfile=$(mktemp)
local tmpfile=/tmp/ssh2seccam0100 # $(tempfile)
local rec macaddr numcol line=1 iplinenum ipline ipaddr devname
#sudo arp-scan --localnet|grep "^192[^\(DUP:]" > ${tmp}
#sudo arp-scan --localnet|grep "^192" > ${tmp}

[ $# -ne 1 ] && {
	echo "${name}:discover_devices_local() req a param"
	return
}
#local start=$(echo $1 | cut -d. -f1)

# $1 : IP addr
get_mac_from_ip()
{
  ip a |grep -B2 $1 |grep "link/ether "|awk '{print $2}'
}

#---
# Local net Host Discovery:
# arp-scan does NOT seem to work reliably
# Use nmap instead! via the 'ARP ping' method
#  ref: https://linuxhint.com/nmap-host-discovery-process/ sec 'ARP Ping'
#  cmd: sudo nmap -sn -PR 192.168.1.0/24
# Eg. o/p:
# ...
# Nmap scan report for 192.168.1.3
# Host is up (0.078s latency).
# MAC Address: B8:27:EB:8B:B1:4E (Raspberry Pi Foundation)
# ...
# -OR-
# Nmap scan report for _gateway (10.20.1.1)
# Host is up (0.0020s latency).
# MAC Address: B8:27:EB:B3:CF:B6 (Raspberry Pi Foundation)
# 
# (Just doing nmap -h shows useful stuff!)
#sudo arp-scan $1/24 | grep "^${start}" > ${tmp}

GATEWAY_IP=$1
sudo rm -f ${tmpfile}
sudo touch ${tmpfile}
sudo nmap -sn -PR ${GATEWAY_IP}/24 --host-timeout 1m -oN ${tmpfile} > /dev/null
[ $? -ne 0 ] && {
	echo "nmap failed; stat=$?" ; return
}

[ ${DEBUG} -eq 1 ] && {
	echo "nmap arp ping $1:
$(cat ${tmpfile})
Press Enter ..."
	read
}
decho() {
[[ ${DEBUG} -eq 1 ]] && echo $*
}

#--- for debug
DEBUG=0
#set -x
#tmpfile=~/usefulsnips/t192dot
#tmpfile=~/usefulsnips/t10dot
#---

IFS=$'\n'
for rec in $(cat ${tmpfile})
#for rec in $(cat t1)
do
  decho "rec= $rec"
  GOT_MACADDR=0
  GOT_DEVNAME=0
  macaddr=""
  devname=""
  ipaddr=""

  # nmap o/p differs depending on the subnet??
  # For 192.168.1.0 I get 5 col o/p NOT including the device name
  #  Eg. 'Nmap scan report for 192.168.1.10'
  # For   10.20.1.0 I get 6 col o/p including the device name (col 5)
  #  Eg. 'Nmap scan report for yeelink-light-lamp4_mibt4AC6.wlan (10.20.1.15)'
  # Check this and accordingly get the device name ...
 
  # Get MAC address
  echo "${rec}" |grep "^MAC Address:" >/dev/null && {
	macaddr=$(echo "${rec}" |awk '{print $3}')
	GOT_MACADDR=1

	devname=$(echo "${rec}" |awk -F\( '{print $2}')
	devname=${devname::-1} # rm the trailing ')'
	[[ ! -z "${devname}" ]] && GOT_DEVNAME=1

	#echo -n "${macaddr},\"${devname}\","
	# 2 lines above this record is the line containing the IP addr
	iplinenum=$((line-2))
	[ ${iplinenum} -le 0 ] && {
	    echo "iplinenum 0 or -ve; something went wrong..."
	    break
	}
	# fetch the line
	ipline=$(sed "${iplinenum}q;d" ${tmpfile})
	#ipline=$(sed "${iplinenum}q;d" t1)
	# f.e. ipline="Nmap scan report for yeelink-light-lamp4_mibt4AC6.wlan (10.20.1.15)"
	decho "
ipline=$ipline
	"

	echo "${ipline}" |grep -E -q "\(.*\)" # esc the () when using egrep, not with grep! # ?
	if [ $? -eq 0 ] ; then  # IP addr is in parentheses: 
			# Of the form:
			#  Nmap scan report for _gateway (192.168.1.1)
		ipaddr=$(echo "${ipline}"|awk '{print $6}')
		ipaddr=${ipaddr:1}   # rm the leading '('
		ipaddr=${ipaddr::-1} # rm the trailing ')'
	else
		# Of the form: 'Nmap scan report for 192.168.1.8'
		ipaddr=$(echo "${ipline}"|awk '{print $5}')
	fi
	#[[ -z "${ipaddr}" ]] && [[ "${devname}" = "_gateway" ]] && echo -n "${GATEWAY_IP},"
	}

	# Under the '^MAC Address:' line, look for 'Nmap scan report for ...' and
	# get the device name there
	echo "${rec}" |grep "^Nmap scan report for" >/dev/null && {
		numcol=$(echo "${rec}" |grep "^Nmap scan report for " |awk '{print NF}')
		decho "numcol = ${numcol}"

		# Eg. 'Nmap scan report for yeelink-light-lamp4_mibt4AC6.wlan (10.20.1.15)'

		# Get the device name
		[[ ${GOT_DEVNAME} -eq 1 ]] && continue
		[[ ${numcol} -eq 6 ]] && {
			devname=$(echo "${rec}" |awk '{print $5}')
			#devname=${devname::-1} # rm the trailing ')'

			# Get the device IP addr
			echo "${rec}" |grep -E -q "\(.*\)"
			if [ $? -eq 0 ] ; then  # IP addr is in parentheses: 
				# Of the form:
				#  Nmap scan report for _gateway (192.168.1.1)
				ipaddr=$(echo "${rec}"|awk '{print $6}')
				ipaddr=${ipaddr:1}   # rm the leading '('
				ipaddr=${ipaddr::-1} # rm the trailing ')'
			else
				ipaddr=$(echo "${rec}"|awk '{print $6}')
			fi
		}
	}
  decho "line=$line: GOT_MACADDR = ${GOT_MACADDR} ***"
  [[ ${GOT_MACADDR} -eq 1 ]] && echo -n "${macaddr},"  || {
	if [[ ! -z "${ipaddr}" ]] && [[ ! -z "${devname}" ]] ; then
	   macaddr=$(get_mac_from_ip ${ipaddr})
	fi
	[[ ! -z "${macaddr}" ]] && echo -n "${macaddr},"
  }
  [[ ! -z "${devname}" ]] && echo -n "${devname}, "
  [[ ! -z "${ipaddr}" ]] && echo "${ipaddr}"

  let line=line+1
done
}

usage()
{
echo "Usage: ${name} [-v|-h] <net-domain1-to-scan> <net-domain2-to-scan> <...>
If the *first* parameter is:
 -v : switch to Verbose mode (default is off)
 -h : show this help screen

F.e.
 ${name} 192.168.1.0 10.20.1.0"
}


##--- 'main' ---
VERBOSE=0
[ $# -eq 0 -o "$1" = "-h" ] && {
	usage
	exit 1
}
[ "$1" = "-v" ] && {
	VERBOSE=1
	shift
}

[ ${VERBOSE} -eq 1 ] && echo "--- $0 ---
CSV format:
MAC_ADDRESS,Device_Name,IP_ADDRESS"

for dom in $@
do
	[ ${VERBOSE} -eq 1 ] && echo "
Scanning for devices in (local) domain ${dom} ..."
	discover_devices_local ${dom}
done
