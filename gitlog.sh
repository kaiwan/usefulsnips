#!/bin/bash
# Displays entire git log in a useful format.
#  Ref: http://githowto.com/history
# intention is to pipe this as input to egrep to look for desired pattern(s).
# Kaiwan NB.
#[ ! -d .git ] && {
# echo ".git missing, aborting..."
# exit 1
#}
git --no-pager log --pretty=format:"%h: %an, %ad : %s" --stat
#git --no-pager log --pretty=format:"%h %ad | %s%d [%an]" --date=short --decorate
echo
