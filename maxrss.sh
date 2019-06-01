#!/bin/bash
# Display the 5 processes that consume the most memory
# Part of the 'usefulsnips' repo here:
# https://github.com/kaiwan/usefulsnips
LOG=/home/$(who|awk '{print $1}')/rssmax.txt
/bin/echo -n "----- " >> ${LOG} 2>&1
/bin/date >> ${LOG} 2>&1
echo "RSS (Resident Set Size): indication of phy mem usage (KB)."
/bin/echo "PID    PPID USER       RSS      COMMAND" >> ${LOG} 2>&1
/bin/ps -o pid,ppid,user,rss,comm -A |sort -k4n -k5 |tail -n5 >> ${LOG} 2>&1
cat ${LOG}
rm -f ${LOG}
echo " (Tip: try with smem(8) as well;
 just try via our prcsmem wrapper!)"
