#!/bin/sh
# WiFi: displays all Access Points, their Quality & signal level;
# simple wrapper over iwlist(8)
sudo iwlist scan 2>/dev/null|grep -B2 "ESSID"
