REM bat script for running netcat receiver - for netconsole
@echo off
title Netconsole Receiver
set logfile="netcon_14jun17.txt"
ECHO "Running: nc64.exe -luv -p 6666 >> %logfile%"
nc64.exe -luv -p 6666 >> %logfile%
