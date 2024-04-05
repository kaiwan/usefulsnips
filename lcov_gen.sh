#!/bin/bash
# lcov_gen.sh
# 
# Quick Description:
# A wrapper over the useful lcov(1) util -  a 'graphical' GCOV front-end.
# Created      : 30May2019
# 
# Author:
# Kaiwan N Billimoria
# kaiwan -at- kaiwantech -dot- com
# kaiwanTECH
# 
# License: MIT

# Turn on unofficial Bash 'strict mode'! V useful
# "Convert many kinds of hidden, intermittent, or subtle bugs into immediate, glaringly obvious errors"
# ref: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail

name=$(basename "$0")
PFX=$(dirname "$(which "$0")")
source "${PFX}/common.sh" || {
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
	echo ">>> $*"
	eval "$*"
}


METADIR=0lcov_meta
MERGE_COVG=1

# Combine all the lcov_meta_*/appfinal.info into a single merged lcov report!
merged_report()
{
local dir tracefile_dirs tracefile LCOV_MERGE_CMD=""

#ls -1d ${METADIR}/* > tmpls
ls -1d 0lcov_meta/* > .tmpls  # CAREFUL! using the meta dir name name literally, else doesn't seem to work ! ???
export IFS=$'\n'
for dir in $(cat .tmpls)
do
  tracefile=${dir}/appfinal.info
  #echo "********************************* tracefile = $tracefile"
  LCOV_MERGE_CMD="${LCOV_MERGE_CMD} --add-tracefile ${tracefile} --test-name $(basename ${dir:2})"
done

LCOV_MERGE_CMD="lcov ${LCOV_MERGE_CMD} --output-file merged.info"
#echo "LCOV_MERGE_CMD = ${LCOV_MERGE_CMD}"
runcmd "${LCOV_MERGE_CMD}"

echo ">>> genhtml -o lcov_merged_html/ -f -t \"Lcov: $(pwd)\" merged.info"
genhtml -o lcov_merged_html/ -f -t "Lcov: $(pwd)" merged.info || echo "genhtml failed"
}

# See lcov(1) for details (under the --initial option)
# Params:
#  $1 : directory of test program
#  $2 : test app
#  $3,$4,... : args to test program
lcov_work()
{
echo " #params: $#; all: $@"

#-- use a different meta-dir each run so that we can later *merge* code coverage results
[[ ${MERGE_COVG} -eq 1 ]] && METADIR_MERGE=${METADIR}/lcovmeta_$(date +%Y%m%d_%H%M%S)
#echo "METADIR_MERGE = $METADIR_MERGE"

(   # sub-shell
cd "$1" || exit 1
mkdir -p "${METADIR_MERGE}" #2>/dev/null

# 1. create baseline coverage data file
runcmd "lcov --capture --initial --directory . --output-file ${METADIR_MERGE}/appbase.info"

# 2. perform test
 local app=$1/$2
 shift ; shift  # get rid of first 2, leaving only the args
 echo ">>> eval ${app} $*"
 eval "${app}" "$@"

 # 3. create test coverage data file; the '.info' file's also called the 'tracefile'
runcmd "lcov --capture --directory . --output-file ${METADIR_MERGE}/apptest.info"

 # 4. combine baseline and test coverage data
 runcmd "lcov --add-tracefile ${METADIR_MERGE}/appbase.info --add-tracefile ${METADIR_MERGE}/apptest.info \
   --output-file ${METADIR_MERGE}/appfinal.info"

 # 5. Generate HTML report
 # pecuiliar: using the runcmd() wrapper here makes genhtml fail ??
 echo ">>> genhtml -o lcov_report/ -f -t "Lcov: "$(pwd)"" ${METADIR_MERGE}/appfinal.info"
 genhtml -o lcov_report/ -f -t "Lcov: $(pwd)" "${METADIR_MERGE}"/appfinal.info || exit 1
 echo "
See this (intermediate) code coverage report via:
 firefox/google-chrome lcov_report/index.html"
 )
 merged_report
}

usage()
{
  echo "Usage: ${name} [-r] app-under-test-pathname arg1 arg2 [...]
 -r : RESET mode: when you pass -r, all existing lcov metadata is deleted,
      in effect giving you a fresh start. DON'T pass it if you'intending to
      run several code coverage test cases one by one, in order to generate a
      merged code coverage report."
}


##### 'main' : execution starts here #####

hash lcov 2>/dev/null || die "Pl install the lcov package first"
hash genhtml 2>/dev/null || die "Pl install the lcov package first"

RESET=0
[ $# -lt 1 ] && {
  usage
  exit 1
}
[ "$1" = "-h" -o "$1" = "--help" ] && {
  usage
  exit 0
}
echo "#params: $#; all: $@"
[ $1 = "-r" ] && {
  RESET=1
  dir=$(dirname "$2")
  app=$(basename "$2")
  shift
} || {
  dir=$(dirname "$1")
  app=$(basename "$1")
}
#echo "reset=${RESET}; dir: ${dir} ; app= ${app} ; args = $*
#"

[ ! -f "${dir}/${app}" ] && {
  echo "${name}: executable \"${dir}/${app}\" not found?"
  exit 1
}

echo "*** ${name} : line coverage (LCOV) reporter wrapper script ***

IMP :: we ASSUME that the program-under-test \"$1\" has been built
with profiling information, i.e., these flags are included
in the Makefile:
   -fprofile-arcs -ftest-coverage -lgcov

FYI: If you land up with this error (typically on Ubuntu 23.10):
 Can't locate lcovutil.pm in @INC (you may need to install the lcovutil module) ...
Pl see:
https://bugs.launchpad.net/ubuntu/+source/lcov/+bug/2029924
"

# clean previous; including the .gcda ! Don't rm the .gcno, its generated on build
rm -rf "${app}"_gcov *.gcda ./*.info lcov_report/ lcov_merged_html/ 2>/dev/null
# Reset? Clean _all_ the lcov metadata - including those of prev runs - if RESET is 1
[[ ${RESET} -eq 1 ]] && {
  echo "<<< RESET mode On: deleting all existing lcov_meta_<foo>/ dirs now ... >>>"
  rm -rf ${METADIR}/
}

shift
lcov_work "${dir}" "${app} $*"

echo "
Done.
--------------------------------- NOTE ---------------------------------------
- If you want a cumulative / merged code coverage report, run your next coverage
test case via this script.
- If you want to start from scratch again, wiping previous coverage data, then
run this script with the -r (reset) option (you can add this to the Maekfile
invoking it if you wish).
------------------------------------------------------------------------------
Once all coverage test cases are run, see the final report here:
 firefox file://$(pwd)/lcov_merged_html/index.html
 or
 google-chrome file://$(pwd)/lcov_merged_html/index.html"
exit 0
