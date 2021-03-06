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
name=$(basename $0)
PFX=$(dirname `which $0`)
source ${PFX}/common.sh || {
 echo "${name}: fatal: could not source ${PFX}/common.sh , aborting..."
 exit 1
}

########### Globals follow #########################
# Style: gNameOfGlobalVar


########### Functions follow #######################

METADIR=lcov_meta
# 
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
lcov -c -i -d . -o ${METADIR}/appbase.info

# 2. perform test
 local app=$1/$2
 shift ; shift  # get rid of first 2, leaving only the args
 echo "eval ${app} $@"
 eval ${app} $@

 # 3. create test coverage data file
 lcov -c -d . -o ${METADIR}/apptest.info

 # 4. combine baseline and test coverage data
 lcov -a ${METADIR}/appbase.info -a ${METADIR}/apptest.info -o ${METADIR}/appfinal.info

 # 5. Generate HTML report
 genhtml -o lcov_report/ -f -t "Lcov: $(pwd)" ${METADIR}/appfinal.info || exit 1
 echo "Report generated here:"
 ls lcov_report/
 )
}

##### 'main' : execution starts here #####

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
"

#echo "all: $@ ; dirname : $(dirname $1)"
dir=$(dirname $1)
app=$(basename $1)
shift
echo "dirname : ${dir} ; app = ${app} ; args = $@"

start ${dir} ${app} $@
exit 0
