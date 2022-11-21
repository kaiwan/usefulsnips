#!/bin/bash
# netconsole: receiver
#  Receives the console output from another system on port 6666
PORT=6666
LOG=~/netcon.log
echo "------------- $(date) -------------" >> ${LOG}
netcat -d -u -l ${PORT} |tee -a ${LOG}
