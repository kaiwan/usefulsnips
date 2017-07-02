#!/bin/bash
# alrm.sh
#
# kaiwan, Oct '09
#

me=$(basename $0)
TITLE="Alarm !!"

# Require 'zenity' installed
which zenity >/dev/null 2>&1 || {
	echo "$me: App \"zenity\" is required (or not in PATH). Install & retry..."
	exit 1
}

if [ $# -lt 1 ]; then
	echo "Usage: $me Alarm-Message-To-Display [Time(min)]"
	echo " Default Timeout: 30min."
	exit 1
fi

echo $#
echo $@
echo $1

SLEEP_TIME=1800	# seconds
if [ ! -z $2 ]; then
	SLEEP_TIME=$(($2*60))
fi

while [ true ]
do
	sleep $SLEEP_TIME
	zenity --title=$TITLE --question --text="$1" || break
done
exit 0

