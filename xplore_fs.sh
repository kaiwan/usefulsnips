#!/bin/bash
# xplore_fs.sh
#
# This is a simple script to help you explore the content of any filesystem!
# Typical use case: to recursively read the ASCII text content of the (pseudo)files
# under pseudo-filesystems like procfs and sysfs!
# 
# Tune the MAXDEPTH variable below to control your descent into fs purgatory :)
# 
# Author: Kaiwan N Billimoria, kaiwanTECH.
# MIT License.

MAX_SZ_KB=100
MAX_LINES=500

# Parameters
# $1 : regular text file to display contents of
display_file()
{
[ $# -eq 0 ] && return
echo "${SEP}"

# Check limits
local sz=$(ls -l $1|awk '{print $5}')
local szkb
let szkb=${sz}/1024
[ ${szkb} -gt ${MAX_SZ_KB} ] && {
  printf "   *** <Skipping, above max allowed size (%ld KB)> ***\n" ${MAX_SZ_KB}
  return
}
local numln=$(wc -l $1|awk '{print $1}')
[ ${numln} -gt ${MAX_LINES} ] && {
  printf "   *** <Skipping, above max allowed lines (%ld)> ***\n" ${MAX_LINES}
  return
}

[ -f $1 ] && cat $1     # display file content
}

###--- "main" here
STARTDIR=/sys/devices
name=$(basename $0)

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
SEP="--------------------------------------------------------------------------"

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
printf "%s\n" ${SEP}

#for sysfile in $(find ${STARTDIR})      # 1-level find; simpler..
for sysfile in $(find -L ${STARTDIR} -xdev -maxdepth ${MAXDEPTH})       # multi-level find; more info..
do
  printf "%-60s " ${sysfile}
  case $(file --mime-type --brief ${sysfile}) in
		inode/symlink) printf ": <slink>\n" ; continue ;;
		inode/directory) printf ": <dir>\n" ; continue ;;
		inode/socket) printf ": <socket>\n" ; continue ;;
		inode/chardevice) printf ": <chardev>\n" ; continue ;;
		inode/blockdevice) printf ": <blockdev>\n" ; continue ;;
		application/x-sharedlib|*zlib) printf ": <binary>\n" ; continue ;;
		application/zip|application/x-xz) printf ": <zip file>\n" ; continue ;;
		text/plain|text/*) printf ": <reg file>\n" ; display_file ${sysfile} ;;
		*) printf ": <-other->\n" ; ls -l ${sysfile} ; continue ;;
  esac
  printf "%s\n" ${SEP}
done
exit 0
