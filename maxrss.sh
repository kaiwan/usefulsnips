#!/bin/bash
# Display the 5 processes that consume the most memory
LOG=/home/kaiwan/rssmax.txt
/bin/echo -n "----- " >> ${LOG} 2>&1
/bin/date >> ${LOG} 2>&1
/bin/echo "PID    PPID USER       RSS      COMMAND" >> ${LOG} 2>&1
/bin/ps -o pid,ppid,user,rss,comm -A |sort -k4n -k5 |tail -n5 >> ${LOG} 2>&1

