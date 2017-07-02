#!/bin/sh
# Displays all Access Points, their Quality & signal level
sudo iwlist scan 2>/dev/null|grep -B2 "ESSID"
