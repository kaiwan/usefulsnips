#!/bin/bash
# pidshow
#
# Shell Script.
#
# Primary objective: 
#  Display useful info about the process.
# Uses procfs to get (most of) the info. 
# 
# Author(s):
# (c) 2012 Kaiwan NB
# 
# URL: 
# http://kaiwantech.wordpress.com/2012/02/23/exploring-linux-procfs-via-shell-scripts/
# 

name=$(basename $0)
. ./common.sh || {
    echo "$name: source failed! common.sh invalid?"
    exit 1
}
SEP='-------------------------------------------------------------------------------'


# With busybox (typically used on an eLinux), the soft-link target in 
# o/p of 'ls -l' is the 11th field (and not the 10th, as on the x86 PC).
# Similar situation with using the 'ps'..
# We have to take this into account...
BBOX=0   # set to 1 if using BusyBox applets (typically on an embedded Linux system)

# function
# @$1 : label string associated with it
# @$2 : pathname to proc file to display
# @$3 : [optional] == "NL" => put a newline after echoing the label @$1
#                    (in fact, we display label as a Title in this case..)
ProcShow()
{
if [ ! -f $2 ]; then
	echo "## Err: file $2 non-existant ##"
	return
fi

if [ "$3" = "NL" ]; then
	ShowTitle "$1"
else
	echo -n "$1 "
fi
cat $2
echo

}


#------------------------------"main"--------------------------
check_root_AIA

VERBOSE=0
if [ $# -ne 2 ]; then
	echo "Usage: $name PID V=[0|1]"
	echo " PID: pid of process whose details will be displayed"
	echo "Verbosity: 0 = non-verbose mode (default)"
	echo "           1 = verbose  mode"
	exit 1
fi

if [ $2 = "1" ]; then
	VERBOSE=1
fi

unalias ls cat 2> /dev/null

RT=/proc/$1
check_folder_AIA $RT

ShowTitle "System Minimal Info"

cat /etc/issue
echo -n "Kernel: "
uname -r
cat /proc/version
echo

#----------------------------------------------------------------------
pidname=$(cat $RT/comm)
echo ${SEP}
ShowTitle "Info for process $pidname TGID $1"
echo ${SEP}

ProcShow "Name:" $RT/comm

KTHREAD=0
# Is it a kernel thread?
# checking by looking for 'ps ax' o/p having name in square brackets [xxx]
# TODO- verify this is ok!
tPID=$1
if [ $BBOX -eq 0 ]; then
	nm=$(ps ax|awk '{print $1, $5}' |grep -w $tPID |cut -f2 -d' ')
else
	nm=$(ps |awk '{print $1, $4}' |grep -w $tPID |cut -f2 -d' ')
fi
firstchar=$(echo ${nm} | awk '{print substr($nm, 1, 1)}')
if [ "${firstchar}" = "[" ]; then
	echo -n "Is "
	KTHREAD=1
else
	echo -n "Is NOT "
fi
echo "a Kernel Thread"

ProcShow "Cmd Line:" $RT/cmdline

# exe
[ ${KTHREAD} -eq 0 ] && {
	echo -n "EXE: "
	# see comment on BBOX at top...
	if [ $BBOX -eq 0 ]; then
		exe=$(ls -l $RT | grep '^l.*exe' |awk '{print $10}')
	else
		exe=$(ls -l $RT | grep '^l.*exe' |awk '{print $11}')
	fi
	echo $exe
	ls -l $exe
}
# cwd
echo -n "CWD: "
if [ $BBOX -eq 0 ]; then
	cwd=$(ls -l $RT | grep '^l.*cwd' |awk '{print $10}')
else
	cwd=$(ls -l $RT | grep '^l.*cwd' |awk '{print $11}')
fi
echo $cwd
# root dir
echo -n "Root Dir: "
if [ $BBOX -eq 0 ]; then
	rootdir=$(ls -l $RT | grep '^l.*root' |awk '{print $10}')
else
	rootdir=$(ls -l $RT | grep '^l.*root' |awk '{print $11}')
fi
echo $rootdir


ProcShow "Control Group(s):" $RT/cgroup
ProcShow "Task Details:" $RT/status NL
ProcShow "Wait channel:" $RT/wchan
ProcShow "Task Stack:" $RT/stack NL

ShowTitle "Open Files:"
ls -l $RT/fd
echo $SEP

echo "Threads:"
numthrds=$(ls $RT/task/ |wc -w)
echo "# threads: $numthrds"
if [ $numthrds -gt 1 ]; then
	echo "PIDs of individual threads belonging to process TGID $1:"
	ls $RT/task/
fi

if [ $VERBOSE -eq 0 ]; then
	echo $SEP
	echo "Done."
	exit 0
fi

#----------------------------VERBOSE-----------------------------------
# Verbose-only

echo
ShowTitle "Verbose Info for process $pidname TGID $1"

ProcShow "cpuset:" $RT/cpuset
[ ${KTHREAD} -eq 0 ] && ProcShow "VM maps:" $RT/maps NL
[ ${KTHREAD} -eq 0 ] && ProcShow "VM smaps:" $RT/smaps NL

ProcShow "stat:" $RT/stat
ProcShow "statm:" $RT/statm
ProcShow "syscall:" $RT/syscall

ProcShow "Coredump filter:" $RT/coredump_filter
ProcShow "I/O:" $RT/io NL
ProcShow "Limits:" $RT/limits NL

ProcShow "oom_adj:" $RT/oom_adj
ProcShow "oom_score:" $RT/oom_score
ProcShow "oom_score_adj:" $RT/oom_score_adj

ProcShow "sched:" $RT/sched NL
ProcShow "schedstat:" $RT/schedstat NL

ProcShow "Environment:" $RT/environ NL
ProcShow "Personality:" $RT/personality
ProcShow "Seccomp filter:" $RT/seccomp_filter

# stack of each thread (loop)
ShowTitle "Per Thread Stack"
n=1
for pid in $(ls $RT/task)
do
#	echo "#$n: thread PID $pid:"
	ProcShow "#$n: thread PID $pid stack:" $RT/task/$pid/stack NL
	n=$((n+1))
done

# TODO:
# pagemap howto ??
# net/ ?



echo
echo $SEP
echo "Done."
exit 0

