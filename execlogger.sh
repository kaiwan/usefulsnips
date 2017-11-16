#!/bin/bash
# Simple wrapper over B Gregg's perf-tools-unstable execsnoop-perf
name=$(basename $0)
PRG=execsnoop   #/home/kai/github_kaiwan_repos/perf-tools/execsnoop #-perf

[ $(id -u) -ne 0 ] && {
 echo "${name}: need root."
 exit 1
}

which ${PRG} >/dev/null || {
#[ -x ${PRG} ] || {
 echo "${name}: \"${PRG}\" not found? PATH issue?"
 exit 1
}

# kill any stale instance
pkill --oldest $(basename ${PRG})

MAXARGS=16
EXECLOG=/home/kai/execlog
HLINE="------------------------------------------------------"
( echo
  echo ${HLINE}
  date
  echo ${HLINE}
) >> ${EXECLOG} 2>&1
${PRG} -t -r -a ${MAXARGS} >> ${EXECLOG} 2>&1
