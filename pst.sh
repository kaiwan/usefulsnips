#!/bin/bash
# pst.sh
# 
# Quick Description:
# Simple but useful wrapper over pstree.
# 
# Last Updated :
# Created      : 22Sep17
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
#PFX=$(dirname `which $0`)
#source ${PFX}/common.sh || {
# echo "${name}: fatal: could not source ${PFX}/common.sh , aborting..."
# exit 1
#}

##### 'main' : execution starts here #####

[ $# -eq 0 ] && {
  echo "Usage: ${name} [PID]"
  #exit 1
}
args="--ascii --arguments --show-pids"
[ $# -eq 1 ] && args="${args} $1"   #--highlight-pid=$1"
pstree ${args}
exit 0
