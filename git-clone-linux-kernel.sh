#!/bin/sh
# Ref: Kernel Hackers' Guide to git
# https://www.kernel.org/doc/man-pages/linux-next.html
# Also:
#  http://linux.yyz.us/git-howto.html , 
#  http://pradheepshrinivasan.github.io/2011/12/29/cloning-linux-next-tree-i-wanted-to-do/ 
#  http://pradheepshrinivasan.github.io/2015/08/05/Tracking-current-in-linux-next/
#
# FYI, one could use 'gitk' to see git repos in a GUI [Ubuntu/Deb]
#  http://gitk.sourceforge.net/
#  http://lostechies.com/joshuaflanagan/2010/09/03/use-gitk-to-understand-git/
# gitg on Fedora/CentOS/RHEL.
#
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# License: Dual MIT/GPL
name=$(basename $0)

REGULAR_TREE=1
LINUX_NEXT_TREE=0  # linux-next: working with the bleeding edge?

echo "${name}: !NOTE! You must specify whether you want to clone the:
 'regular' kernel src tree (by setting REGULAR_TREE=1 and LINUX_NEXT_TREE=0 in this script), 
-or-
 'linux-next' kernel src tree (by setting REGULAR_TREE=0 and LINUX_NEXT_TREE=1 in this script).

Currently, REGULAR_TREE=${REGULAR_TREE}, LINUX_NEXT_TREE=${LINUX_NEXT_TREE}

Press [Enter] to continue, or ^C to exit ...
"
read -r x

if [ ${REGULAR_TREE} -eq 1 -a ${LINUX_NEXT_TREE} -eq 1 ] ; then
  echo "${name}: Both 'regular' and 'linux-next' can't be cloned, choose one of them pl.."
  exit 1
fi
if [ ${REGULAR_TREE} -eq 0 -a ${LINUX_NEXT_TREE} -eq 1 ] ; then
  [ $# -ne 1 ] && {
     echo "Working with linux-next:"
	 echo "Usage: ${name} new-branch-to-work-under"
     exit 1
  }
  NEW_BRANCH=$1
fi

[ ${REGULAR_TREE} -eq 1 ] && {
  GITURL=https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
  echo "[+] ${name}: cloning 'regular' linux kernel now ... (this can take a while)..."
  echo "Running: time git clone ${GITURL}"
  time git clone ${GITURL}
}
# For 'regular': to update to latest:
# git pull ${GITURL}
# or just
# git pull

[ ${LINUX_NEXT_TREE} -eq 1 ] && {
# ref: https://www.kernel.org/doc/man-pages/linux-next.html
GITURL_MAIN=https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
echo "[+] time git clone ${GITURL_MAIN}"
time git clone ${GITURL_MAIN}
cd linux || exit 1

GITURL_NEXT=https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
echo "[+] git remote add ${GITURL_NEXT}"
git remote add linux-next ${GITURL_NEXT}

echo "[+] git fetch linux-next"
git fetch linux-next
echo "[+] git fetch --tags linux-next"
git fetch --tags linux-next

git checkout master      # to be safe
echo "[+] git remote update"
git remote update

echo "[+] git tag -l \"next-*\""
git tag -l "next-*"

# Select the tag u want
echo "[+] Type in the tag you want: "
read NEXT_TAG

echo "[+] git checkout -b ${NEW_BRANCH} ${NEXT_TAG}"
git checkout -b ${NEW_BRANCH} ${NEXT_TAG}
}
# Done!
