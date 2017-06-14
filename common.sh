#!/bin/bash
#------------------------------------------------------------------
# common.sh
#
# Common convenience routines
# 
# (c) Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# MIT License
# Last Updt: 27Mar2017
#------------------------------------------------------------------

export TOPDIR=$(pwd)
ON=1
OFF=0

### UPDATE for your box
. ./err_common.sh || {
 echo "$name: could not source err_common.sh, aborting..."
 exit 1
}


# DesktopNotify
# Ubuntu desktop notify-send wrapper func
# Parameter(s)
#  $1 : String to display in desktop notification message [required]
function DesktopNotify()
{
	# Ubuntu : notify-send !
	[ $# -ne 1 ] && MSG="<bug: no message parameter :)>" || MSG="$1"
	notify-send --urgency=low "${MSG}"
}


# genLogFilename
# Generates a logfile name that includes the date/timestamp
# Format:
#  ddMmmYYYY[_HHMMSS]
# Parameter(s)
# #$1 : String to prefix to log filename, null okay as well [required]
#  $1 : Include time component or not [required]
#    $1 = 0 : Don't include the time component (only date) in the log filename
#    $1 = 1 : include the time component in the log filename
genLogFilename()
{
 [ $1 -eq 0 ] && log_filename=$(date +%d%b%Y)
 [ $1 -eq 1 ] && log_filename=$(date +%d%b%Y_%H%M%S)
 echo ${log_filename}
}

# Debug echo :-)
decho()
{
  Prompt "$@"
}

debug_verbose=0
# Echo
# Echo string (with timestamp prefixed) to stdout and to Log file 
# if so specified.
# Parameter(s):
#  $1 : String to display to stdout [required]
#  $2 : Log pathname to also append the $1 string to [optional]
Echo()
{
#echo "# p = $#"
	[ $# -eq 0 ] && return 1
	[ ${debug_verbose} -eq 1 ] && {
	   [ ! -z "${name}" ] && echo -n "${name}:"
	   echo -n "$(date):"
	   echo "$1"
	   [ $# -ge 2 ] && {
	      [ -f $2 -a -w $2 ] && {
	         echo -n "$(date) : " >> $2
	         echo "$1" >> $2
	 	  }
  	   }
    }
}


# ShowTitle
# Display a string in "title" form
# Parameter(s):
#  $1 : String to display [required]
# Returns: 0 on success, 1 on failure
ShowTitle()
{
	[ $# -ne 1 ] && return 1
	SEP='-------------------------------------------------------------------------------'
	echo $SEP
	echo $1
	echo $SEP
}

# check_root_AIA
# Check whether we are running as root user; if not, exit with failure!
# Parameter(s):
#  None.
# "AIA" = Abort If Absent :-)
check_root_AIA()
{
	if [ `id -u` -ne 0 ]; then
		echo "Error: need to run as root! Aborting..."
		exit 1
	fi
}

# check_file_AIA
# Check whether the file, passed as a parameter, exists; if not, exit with failure!
# Parameter(s):
#  $1 : Pathname of file to check for existence. [required]
# "AIA" = Abort If Absent :-)
# Returns: 0 on success, 1 on failure
check_file_AIA()
{
	[ $# -ne 1 ] && return 1
	[ ! -f $1 ] && {
		echo "Error: file \"$1\" does not exist. Aborting..."
		exit 1
	}
}

# check_folder_AIA
# Check whether the directory, passed as a parameter, exists; if not, exit with failure!
# Parameter(s):
#  $1 : Pathname of folder to check for existence. [required]
# "AIA" = Abort If Absent :-)
# Returns: 0 on success, 1 on failure
check_folder_AIA()
{
	[ $# -ne 1 ] && return 1
	[ ! -d $1 ] && {
		echo "Error: folder \"$1\" does not exist. Aborting..."
		exit 1
	}
}

# check_folder_createIA
# Check whether the directory, passed as a parameter, exists; if not, create it!
# Parameter(s):
#  $1 : Pathname of folder to check for existence. [required]
# "IA" = If Absent :-)
# Returns: 0 on success, 1 on failure
check_folder_createIA()
{
	[ $# -ne 1 ] && return 1
	[ ! -d $1 ] && {
		echo "Folder \"$1\" does not exist. Creating it..."
		mkdir -p $1	&& return 0 || return 1
	}
}


# GetIP
# Extract IP address from ifconfig output
# Parameter(s):
#  $1 : name of network interface (string)
# Returns: IPaddr on success, non-zero on failure
GetIP()
{
	[ $# -ne 1 ] && return 1
	ifconfig $1 >/dev/null 2>&1 || return 2
	ifconfig $1 |grep 'inet addr'|awk '{print $2}' |cut -f2 -d':'
}

# get_yn_reply
# User's reply should be Y or N.
# Returns:
#  0  => user has answered 'Y'
#  1  => user has answered 'N'
get_yn_reply()
{
echo -n "Type Y or N please (followed by ENTER) : "
str="${@}"
while true
do
   echo ${str}
   read reply

   case "$reply" in
   	y | yes | Y | YES ) 	return 0
			;;
   	n* | N* )		return 1
			;;	
   	*)	echo "What? Pl type Y / N" 
   esac
done
}

# MountPartition
# Mounts the partition supplied as $1
# Parameters:
#  $1 : device node of partition to mount
#  $2 : mount point
# Returns:
#  0  => mount successful
#  1  => mount failed
MountPartition()
{
[ $# -ne 2 ] && {
 echo "MountPartition: parameter(s) missing!"
 return 1
}

DEVNODE=$1
[ ! -b ${DEVNODE} ] && {
 echo "MountPartition: device node $1 does not exist?"
 return 1
}

MNTPT=$2
[ ! -d ${MNTPT} ] && {
 echo "MountPartition: folder $2 does not exist?"
 return 1
}

mount |grep ${DEVNODE} >/dev/null || {
 #echo "The partition is not mounted, attempting to mount it now..."
 mount ${DEVNODE} -t auto ${MNTPT} || {
  echo "Could not mount the '$2' partition!"
  return 1
 }
}
return 0
}


#------------------- Colors!! Yay :-) -----------------------------------------
# Ref: http://tldp.org/LDP/abs/html/colorizing.html
black='\E[30;47m'
red='\E[31;47m'
green='\E[32;47m'
yellow='\E[33;47m'
blue='\E[34;47m'
magenta='\E[35;47m'
cyan='\E[36;47m'
white='\E[37;47m'
 
#  Reset text attributes to normal without clearing screen.
Reset()
{ 
   tput sgr0 
} 

# !!!
# Turn this ON for COLOR !!!
# !!!
COLOR=${OFF}
#COLOR=${ON}

# Color-echo.
#  Argument $1 = message
#  Argument $2 = color
# Usage eg.:
# cecho "This message is in blue!" $blue
cecho ()                     
{
local default_msg="No message passed."
                             # Doesn't really need to be a local variable.
[ ${COLOR} -eq 0 ] && {
  echo $1
  return
}
#echo "cecho: nump = $# : $@"

message=${1:-$default_msg}   # Defaults to default message.
color=${2:-$black}           # Defaults to black, if not specified.

  echo -e "$color"
  echo "$message"
  Reset                      # Reset to normal.

  return
}  
#----------------------------------------------------------------------


## is_kernel_thread
# Param: PID
# Returns:
#   1 if $1 is a kernel thread, 0 if not, 127 on failure.
is_kernel_thread()
{
[ $# -ne 1 ] && {
 echo "is_kernel_thread: parameter missing!" 1>&2
 return 127
}

prcs_name=$(ps aux |awk -v pid=$1 '$2 == pid {print $11}')
#echo "prcs_name = ${prcs_name}"
[ -z ${prcs_name} ] && {
 echo "is_kernel_thread: could not obtain process name!" 1>&2
 return 127
}

firstchar=$(echo "${prcs_name:0:1}")
#echo "firstchar = ${firstchar}"
len=${#prcs_name}
let len=len-1
lastchar=$(echo "${prcs_name:${len}:1}")
#echo "lastchar = ${lastchar}"
[ ${firstchar} = "[" -a ${lastchar} = "]" ] && return 1 || return 0
}

#----------------------------------------------------------------------
# display_file_range
# $1 : pathname of file to display
# $2 : start line number (can be '-' => from line 1)
# $3 : end line number (can be '-' => to end)
display_file_range()
{
if [ $# -ne 3 ]; then
	echo "Usage: $0 filename start-line end-line"
	return
fi

#--- Sanity checks
if [ ! -f $1 ]; then
	echo "$0: File error: $1 not found or is not a regular file"
	return 1
fi
if [ ! -r $1 ]; then
	echo "$0: File error: $1 not readable"
	return 1
fi

# check whether $1 is binary..how??
#TYPE_ASCII='ASCII text'
#file $1 |grep "$TYPE_ASCII" >/dev/null 2>&1 || { \
#	echo "$0: File type error: file to be ranged should be an ASCII file."
#	return 1
#}

start_line=$2
end_line=$3
total_lines=$(wc -l $1|awk '{print $1}')

if [ $total_lines -eq 0 ]; then
	echo "$0: File error: $1 is empty"
	return 1
fi

if [ $start_line = "-" ]; then
	start_line=1
elif [ $start_line -le 0 ]; then
	start_line=1
fi

if [ $end_line = "-" ]; then
	end_line=$total_lines
elif [ $end_line -gt $total_lines ]; then
	end_line=$total_lines
fi
if [ $end_line -le 0 ]; then
	echo "$0: Invalid range: Negative end line"
	return 1
fi
#if [ $end_line -le $start_line ]; then
#	echo "$0: Invalid range: End line should be greater then Start line"
#	return 1
#fi
if [ $start_line -gt $total_lines ]; then
	echo "$0: Invalid range: Start line should be less then total lines"
	return 1
fi

#------------------------------- Actual job
tailvar=$(($end_line-$start_line+1))
#if [ $DEBUG -eq 1 ]; then
#	echo 'start_line=' $start_line
#	echo 'end_line=' $end_line
#	echo 'tailvar=' $tailvar
#fi
head -n$end_line $1 | tail -n$tailvar
} # end display_file_range()

#----------------------------------------------------------------------
# runcmd
# Parameter(s):
# $1 : description string              [Required]; (passing NUL str ok)
# $2 : command to execute via a shell  [Required]
# Return:
#  return status ($?) of the command $1
runcmd()
{
  [ $# -lt 2 ] && return
  Echo "$1"
  eval $2
  return $?
}
# end runcmd()
