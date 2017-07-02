#!/bin/bash
# xplore_fs.sh
#
# This is a simple script to help you explore the content of any filesystem!
# Typical use case: to recursively read the ASCII text content of the (pseudo)files
# under pseudo-filesystems like procfs and sysfs!
# 
# Tune the MAXDEPTH variable below to control your descent into sysfs :)
# 
# Author: Kaiwan N Billimoria.
#

STARTDIR=/sys/devices
name=$(basename $0)
#[ `id -u` -ne 0 ] && {
# echo "${name}: need to run as root. Can do 'sudo <path/to/>${name}'"
# exit 1
#}

[ $# -ne 1 ] && {
 echo "Usage: ${name} start-dir"
 #echo "Expect that the 'start-dir' is a folder in /sys. Specify full pathname."
 exit 1
}
[ ! -d $1 ] && {
 echo "${name}: '$1' invalid folder. Aborting..."
 exit 1
}
[ ! -r $1 ] && {
 echo "${name}: '$1' not read-able, re-run this utility as root (with sudo)? Aborting..."
 exit 1
}
STARTDIR=$1
MAXDEPTH=4
SEP="------------"

SHOW_SUMMARY=0
if [ ${SHOW_SUMMARY} -eq 1 ]; then
	echo "===================== SUMMARY LIST of Files =========================="
	echo
	echo "Note: Max Depth is ${MAXDEPTH}."
	echo
	find -L ${STARTDIR} -xdev -maxdepth ${MAXDEPTH}       # multi-level find; more info..
	echo
	echo
fi
printf " -----------------------------------------------------------------------\n"

regex_num='^[0-9]+$'

#for sysfile in $(find ${STARTDIR})      # 1-level find; simpler..
for sysfile in $(find -L ${STARTDIR} -xdev -maxdepth ${MAXDEPTH})       # multi-level find; more info..
do
  printf "%-60s " ${sysfile}

  if [ -d ${sysfile} ]; then
  	printf ": <dir>\n"
  elif [ -f ${sysfile} ]; then
  	printf ": "
	if [ -r ${sysfile} ]; then
		val=$(cat ${sysfile}) || continue
		if [[ ${val} =~ ${regex_num} ]] ; then  # is it a number?
		   printf "%12d " ${val}
		   [ ${val} -gt 1024 ] && {
		      valkb=$((val/1024))
			  printf "(%6d K)" ${valkb}
		   }
		   [ ${val} -gt 1048576 ] && {
		      valmb=$(bc <<< "${val}/1048576.0")  # TODO - not getting floating point value !??
		      #valmb=$((val/1048576.0))
			  printf "(%6.2f M)" ${valmb}
		   }
		   [ ${val} -gt 1073741824 ] && {
		      valgb=$((val/1073741824))
			  printf "(%6.2f G)" ${valgb}
		   }
		else
		   #printf "%s" ${val}
		   echo "${val}"
		fi
		printf "\n"
		#echo "   ${val}" #$(cat ${sysfile})"
	fi
  elif [ -L ${sysfile} ]; then
  	printf ": <slink>\n"
	echo "  $(ls -l ${sysfile})"
  fi
done

