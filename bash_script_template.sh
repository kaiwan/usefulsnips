#!/bin/bash

name=$(basename $0)

die()
{
echo >&2 "FATAL: $*" ; exit 1
}
warn()
{
echo >&2 "WARNING: $*"
}

# runcmd
# Parameters
#   $1 ... : params are the command to run
runcmd()
{
	[[ $# -eq 0 ]] && return
	echo "$@"
	eval "$@"
}


#--- 'main'


exit 0
