#!/bin/bash
# show_dhcp_cli.sh
# 
# Quick Description:
# Show all DHCP (IP and MAC) addresses for a given network interface.
# A (useful?) and simple wrapper over arp-scan.
# 
# Last Updated : 03Dec2018
# Created      : 03Dec2018
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

usage() {
cat << EOM
Usage: ${name} [network-interface]

The first optional parameter is the network interface to scan; if not
specified, we shall search for and use the WiFi interface."
EOM
}

show_available_intf()
{
  echo "FYI, these are the valid interfaces on the system:"
  ls /sys/class/net
}

### "main" here
if [ "$1" = "-h" -o "$1" = "--help" ] ; then
	usage
	exit 0
fi

# To do so, we know that it begins with 'wl' and Ethernet with 'en'; how?
# The spec is here: 
# https://github.com/systemd/systemd/blob/master/src/udev/udev-builtin-net_id.c
# ...
# <BS>Two character prefixes based on the type of interface:
# *   en — Ethernet
# *   ib — InfiniBand
# *   sl — serial line IP (slip)
# *   wl — wlan
# *   ww — wwan

intf=wlo1
[ $# -eq 1 ] && {
  [ "$1" = "lo" ] && {
    echo "${name}: cannot use 'lo' as interface"
    show_available_intf
    exit 1
  }
  intf=$1
}

echo "### ${name}: taking \"${intf}\" as the network interface"
show_available_intf
echo
sudo arp-scan --interface=${intf} --localnet
