#!/bin/bash
# lcov_gen.sh
# 
# Quick Description:
# A wrapper over the useful lcov(1) util -  a 'graphical' GCOV front-end.
# 
# Last Updated :
# Created      : 30May2019
# 
# Author:
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# 
# License:
# MIT License.

# Turn on unofficial Bash 'strict mode'! V useful
# "Convert many kinds of hidden, intermittent, or subtle bugs into immediate, glaringly obvious errors"
# ref: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

name=$(basename $0)
PFX=$(dirname `which $0`)
source ${PFX}/common.sh || {
 echo "${name}: fatal: could not source ${PFX}/common.sh , aborting..."
 exit 1
}

die()
{
echo >&2 "FATAL: $*"
exit 1
}

# runcmd
# Parameters
#   $1 ... : params are the command to run
runcmd()
{
	[ $# -eq 0 ] && return
	echo "$@"
	eval "$@"
}

METADIR=lcov_meta
# See lcov(1) for details (under the --initial option)
# Params:
#  $1 : directory of test program
#  $2 : test app
#  $3,$4,... : args to test program
start()
{
(   # sub-shell
cd $1 || exit 1
mkdir -p ${METADIR} 2>/dev/null

# 1. create baseline coverage data file
lcov --capture --initial --directory . --output-file ${METADIR}/appbase.info
#lcov -c -i -d . -o ${METADIR}/appbase.info

# 2. perform test
 local app=$1/$2
 shift ; shift  # get rid of first 2, leaving only the args
 echo "eval ${app} $@"
 eval ${app} $@

 # 3. create test coverage data file
lcov --capture --directory . --output-file ${METADIR}/apptest.info
 #lcov -c -d . -o ${METADIR}/apptest.info

 # 4. combine baseline and test coverage data
 lcov --add-tracefile ${METADIR}/appbase.info --add-tracefile ${METADIR}/apptest.info \
   --output-file ${METADIR}/appfinal.info
 #lcov -a ${METADIR}/appbase.info -a ${METADIR}/apptest.info -o ${METADIR}/appfinal.info

 # 5. Generate HTML report
 genhtml -o lcov_report/ -f -t "Lcov: $(pwd)" ${METADIR}/appfinal.info || exit 1
 echo "Report generated here:"
 ls lcov_report/
 )
}

##### 'main' : execution starts here #####

hash lcov 2>/dev/null || die "Pl install the lcov package first"
hash genhtml 2>/dev/null || die "Pl install the lcov package first"

[ $# -lt 1 ] && {
  echo "Usage: ${name} app-under-test-pathname arg1 arg2 [...]"
  exit 1
}
[ ! -f $1 ] && {
  echo "${name}: \"$1\" not existing?"
  exit 1
}

echo "*** LCOV : line coverage reporter ***

IMP :: we ASSUME that the program-under-test \"$1\" has been built
with profiling information, i.e., these flags are included
in the Makefile:
   -fprofile-arcs -ftest-coverage

FYI: If you land up with this error (typicaly on Ubuntu):
 Can't locate lcovutil.pm in @INC (you may need to install the lcovutil module) ...
pl see:
https://bugs.launchpad.net/ubuntu/+source/lcov/+bug/2029924
"

#echo "all: $@ ; dirname : $(dirname $1)"
dir=$(dirname $1)
app=$(basename $1)
shift
echo "dirname : ${dir} ; app = ${app} ; args = $@"

start ${dir} ${app} $@
exit 0
