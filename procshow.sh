#!/bin/sh
# proc_show.bash
#
# Conveniently displays/demos features of procfs at a "global / macro" level
# (meaning, not per-process or thread).
# 
# * Author: Kaiwan N Billimoria <kaiwan@designergraphix.com>
#
# URL: 
# http://kaiwantech.wordpress.com/2012/02/23/exploring-linux-procfs-via-shell-scripts/
# 

INTERACTIVE=0   # make 1 to make this script "interactive"
LINE="----------------------------------------------------------------------------"
DBL_LINE="============================================================================"

show_cmd()
{
	echo $LINE
	echo $@
	echo $LINE

	# run it!
	cmd=$@
	/bin/sh -c "$cmd"

	echo $LINE
	if [ $INTERACTIVE -eq 1 ]; then
		echo "Press Enter to continue, ^C to abort..."
		read
	fi
}

#--------------- "main" ------------------
if [ `id -u` -ne 0 ]; then
	echo "$0: Need to be root."
	exit 1
fi

cmd="cd /proc ; pwd ; ls --color=auto -F"
show_cmd $cmd

#--- I-A : procfs as a Viewport to Hardware & Kernel Information .................
echo
echo $DBL_LINE
echo "procfs as a Viewport to Hardware & Kernel Information ................."
echo $DBL_LINE

cmd="cd /proc/ ; ls -lF --color=auto |grep '^[^d]'"
show_cmd $cmd

cmd="cat /proc/cpuinfo"
show_cmd $cmd

echo "Number of processor cores:"
cmd="find /sys/devices/system/cpu/ -type d |grep 'cpu[0-9]$' |wc -l"
show_cmd $cmd

cmd="cat /proc/interrupts"
show_cmd $cmd

#--- I-B : procfs as a Viewport to Software Information .................
echo
echo $DBL_LINE
echo "procfs as a Viewport to Software Information ................."
echo $DBL_LINE

cmd="uname -a"
show_cmd $cmd
cmd="cat /proc/version"
show_cmd $cmd

cmd="cat /proc/buddyinfo"
show_cmd $cmd

cmd="cat /proc/cmdline"
show_cmd $cmd

cmd="grep register_chrdev /proc/kallsyms"
show_cmd $cmd
cmd="grep sys_call_table /proc/kallsyms"
show_cmd $cmd

#------------------ Kernel Tuning :: sysctl
echo
echo $DBL_LINE
echo "procfs for kernel Tuning : sysctl ................."
echo $DBL_LINE

cmd="cd /proc/sys ; ls --color=auto -F"
show_cmd $cmd

cmd="cd /proc/sys/kernel ; ls --color=auto -F"
show_cmd $cmd

cmd="cd /proc/sys/kernel ; cat msgmni msgmnb msgmax"
show_cmd $cmd

#-------------------- sysctl.conf
echo
echo $DBL_LINE
echo "sysctl: Making changes to procfs permanant : /etc/sysctl.conf ................."
echo $DBL_LINE

cmd="tail /etc/sysctl.conf"
show_cmd $cmd

#cmd="sysctl -A 2>/dev/null |grep -C5 'kernel\.sysrq' 2>/dev/null"
#show_cmd $cmd

echo "Done."
exit 0

