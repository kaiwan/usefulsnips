#!/bin/bash
# Simple wrapper over execsnoop from the BPF tools package
name=$(basename $0)
PRG=execsnoop-bpfcc

[ $(id -u) -ne 0 ] && {
 echo "${name}: need root."
 exit 1
}

which ${PRG} >/dev/null || {
 echo "${name}: \"${PRG}\" not found? PATH issue?
Tip- On Ubuntu/Debian, install the bpfcc-tools package"
 exit 1
}

# kill any stale instance
pkill --oldest $(basename ${PRG})

EXECLOG=~/execlog
HLINE="------------------------------------------------------"
( echo
  echo ${HLINE}
  date
  echo ${HLINE}
) >> ${EXECLOG} 2>&1
${PRG} -T -U >> ${EXECLOG} 2>&1
