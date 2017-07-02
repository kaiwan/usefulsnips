#!/bin/bash
# Simple wrapper over B Gregg's perf-tools-unstable execsnoop-perf
PRG=execsnoop-perf
which ${PRG} >/dev/null || {
 echo "${PRG} not found? PATH issue?"
 exit 1
}
[ $(id -u) -ne 0 ] && {
 echo "${PRG} requires root"
 exit 1
}

# kill any stale instance
pkill --oldest ${PRG} #$(basename $0) 

MAXARGS=16
EXECLOG=xlog
HLINE="------------------------------------------------------"
( echo
  echo ${HLINE}
  date
  echo ${HLINE}
) >> ${EXECLOG} 2>&1
${PRG} -t -r -a ${MAXARGS} >> ${EXECLOG} 2>&1
