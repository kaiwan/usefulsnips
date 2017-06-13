#!/bin/bash
# 0setup.bash
# Convenience startup script
#
# You must run this as:
# $ . /0setup.bash
#
# Don't miss the ". " syntax!
# 
# Part of the Seawolf Appliance
# (c) kaiwanTECH

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

pushd . >/dev/null

PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:~/Dropbox/bin:~/Dropbox/bin/utils-knb
# Mentor Graphics CodeSourcery toolchain: aarch64-buildroot-linux-gnu- 
PATH=$PATH:~/MentorGraphics/Sourcery_CodeBench_Lite_for_ARM_GNU_Linux/bin
# Buildroot toolchain: aarch64-buildroot-linux-gnu- 
PATH=$PATH:/mnt/big/scratchpad/source_trees/buildroot/output/host/usr/bin

BASH_ENV=$HOME/.bashrc
export BASH_ENV PATH
unset USERNAME

[ `id -u` -eq 0 ] && export PS1='# ' || export PS1='$ '

# Aliases

alias see='echo -n "date:" ; date; echo -n "distro:" ; head -n1 /etc/issue ; echo -n "kernel:" ; cat /proc/version; echo -n "cpu:" ; grep "model name" /proc/cpuinfo |uniq |cut -d: -f2; echo -n "uptime:" ; w|head -n1; acpi 2>/dev/null; echo "Syncing...:" ;sync;sync;sync'
alias b='acpi' # battery

alias cl='clear'
alias ls='ls -F --color=auto'
alias l='ls -lFh --color=auto'
alias ll='ls -lF --color=auto'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'

alias dmesg='/bin/dmesg --human --decode --reltime --nopager'
alias dm='/bin/dmesg --human --decode --reltime --nopager|tail -n35'
alias jlog='/bin/journalctl -am --no-pager'
alias jlogt='/bin/journalctl -am --no-pager|tail -n30'
alias lsh='lsmod | head'
alias db='dropbox status'

alias grep='grep --color=auto'
alias s='echo "Syncing.."; sync; sync; sync'
alias d='df -h|grep "^/dev/"'
alias f='free -ht'
alias ma='mount -a; df -h'

alias py='ping -c3 yahoo.com'
alias inet='netstat -a|grep ESTABLISHED'
#--------------------ps stuff
# custom recent ps
alias rps='ps -o user,pid,rss,stat,time,command -Aww |tail -n30'
# custom ps sorted by highest CPU usage
alias rcpu='ps -o %cpu,%mem,user,pid,rss,stat,time,command -Aww |sort -k1n'
alias pscpu='ps aux|sort -k3n'
#------------------------------------------------------------------------------

#alias vim='vim $@ >/dev/null 2>&1'
#alias vimc='vim *.[ch] Makefile *.sh'

popd >/dev/null

# Ubuntu
alias sd='sudo /bin/bash'

# console debug: show all printk's on the console
[ `id -u` -eq 0 ] && echo -n "8 4 1 7" > /proc/sys/kernel/printk

###
# Some useful functions
###

# xdf: http://smokey01.com/yad/
function xdf()
{
eval yad --title="xdf" --image=drive-harddisk --text="Disk\ usage:" \
      --buttons-layout=end --width=650 --multi-progress \
	  $(df -hT $1 | tail -n +2 | \
	   awk '{printf "--bar=\"<b>%s</b> (%s - %s) [%s/%s]\" %s ", $7, $1, $2, $4, $3, $6}')
}

function mem()
{
 echo "PID    RSS    WCHAN            NAME"
 ps -eo pid,rss,wchan:16,comm |sort -k2n
 echo
 echo "Note: 
 -Output auto-sorted by RSS (Resident Set Size)
 -RSS is expressed in KB!"
}

# dtop: useful wrapper over dstat
dtop()
{
DLY=5
echo dstat --time --top-io --top-cpu --top-mem ${DLY}
 #--top-latency-avg
dstat --time --top-io --top-cpu --top-mem ${DLY}
 #--top-latency-avg
}


#---------------------------- GIT ------------------------
# shortcut for git SCM
# aliases: see https://www.linux.com/blog/git-success-stories-and-tips-kvm-maintainer-paolo-bonzini
alias gdiff='git diff -r'
alias gfiles='git diff --name-status -r'
alias gstat='git diff --stat -r'

# -to add a file(s) and then commit it with a commit msg
function gitac()
{
 [ $# -ne 2 ] && {
  echo "Usage: gitac filename \"commit-msg\""
  return
 }
 echo "git add $1 ..."
 git add $1
 echo "git commit -m ..."
 git commit -m "$2"
}
#---------------------------------------------------------

# Show thread(s) running on cpu core 'n'  - func c'n'
function c0()
{
ps -eLF |awk '{ if($5==0) print $0}'
}
function c1()
{
ps -eLF |awk '{ if($5==1) print $0}'
}
function c2()
{
ps -eLF |awk '{ if($5==2) print $0}'
}
function c3()
{
ps -eLF |awk '{ if($5==3) print $0}'
}

# end 0setup.bash
