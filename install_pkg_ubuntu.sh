#!/bin/bash
# ac.sh
#
# Last Updated : 08 Oct 2015
# Created      : 05 Sep 2015
# 
# Author:
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# 
name=$(basename $0)
source ./common.sh || {
 echo "$name: could not source common.sh , aborting..."
 exit 1
}

########### Functions follow #######################

install_custom_packages()
{
DUMMY_RUN=0

#--------------
#[ 1 -eq 1 ] && {  # closest we get to C's #ifdef 0 / 1    :-)
#job1="apt-get --yes update"
job1='apt-get --yes install git gitk'
job2="apt-get --yes install crash"
job3="apt-get --yes install htop nmon numactl iptraf dstat sysstat iotop iftop ethtool" # sysstat=>sar
job4="apt-get --yes install clamav clamtk" # antivirus

# perf  !CAREFUL! watch the kernel ver.
job5="apt-get --yes install linux-tools-common linux-tools-$(uname -r) perf-tools-unstable"  # perf

job6="apt-get --yes install libncurses5-dev" # for menuconfig
job7="apt-get --yes install qemu-kvm qemu-system-x86 qemu-system-arm"
job8="apt-get --yes install cscope exuberant-ctags"
job9="apt-get --yes install vim p7zip-full"
job10="apt-get --yes install debootstrap gparted"
job11="apt-get --yes install valgrind"
job12="apt-get --yes install fortune cowsay"
job13="apt-get --yes install open-vm-tools" # VMware Guest Tools!
job14="apt-get --yes install sysfstools" # systool, etc
job15="apt-get --yes install lxc lxd-client" # LXC containers
job16="apt-get --yes install freemind" # Mind Maps
job17="apt-get --yes autoremove"

###
# We'll use an array 'work' to hold all the jobs.
# And then iterate through them, running each job and simultaneously piping the 
# output to the zenity progress bar (as well as stdout tty device and a tmp file)!
i=1
IFS=$'\n'

# !CAREFUL! Maintain this array to match the job strings!
work=( \
  ${job1} \
  ${job2} \
  ${job3} \
  ${job4} \
  ${job5} \
  ${job6} \
  ${job7} \
  ${job8} \
  ${job9} \
  ${job10} \
  ${job11} \
  ${job12} \
  ${job13} \
  ${job14} \
  ${job15} \
  ${job16} \
  ${job17} \
)  # !CAREFUL! Maintain this array to match the job strings!

# IMP!
[ ${DUMMY_RUN} -eq 0 ] && apt-get update

export len=${#work[@]}
(
i=1
IFS=$'\n'

for job in "${work[@]}"
do
  echo
  echo "----------------------------------------------------" 

  jobnum="job${i}"
  echo "# ${jobnum}: ${job}"
  # Execute it
  [ ${DUMMY_RUN} -eq 0 ] && {
    eval "${job}"              #| tee --append .tmp${i}
    [ ${?} -ne 0 ] && {
     echo
     echo "****** !WARNING! Job \"${job}\" FAILed ******"
     echo
    }
  }
  let i=i+1
  sleep 1
done

echo "# All finished."
)

rm -f .tmp* 2>/dev/null
if [ "$?" != 0 ] ; then
  echo "Job(s) Failed??"
fi
######################################


} # end install_custom_packages()

remove_unrequired()
{
apt-get -y remove thunderbird apport
# cleanup
echo "
Cleaning up now!"
sudo apt-get -f install &&
sudo apt-get autoremove &&
sudo apt-get -y autoclean &&
sudo apt-get -y clean
apt-get -y remove abiword* apport* audacious* gnumeric* guvcview* xfburn* mtpaint* simple-scan* usb-creator-gtk* sylpheed*
} # end remove_unrequired()

main()
{
check_root_AIA
echo "-------------- SPACE ------------------"
df -h
echo
install_custom_packages
remove_unrequired
echo "-------------- SPACE ------------------"
df -h
echo

# Change core file naming:
# "core_<hostname>_<PID>_<UID>_<signal#>_<executable_filename>"
echo "core_%h_%p_%u_%s_%e" > /proc/sys/kernel/core_pattern
}

##### execution starts here #####

main
exit 0
