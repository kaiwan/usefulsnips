#!/bin/bash
# genmk
# Generate a simple Makefile for a typical 'C' systems application
# running on Linux.
#
# (c) 2018 Kaiwan N Billimoria, kaiwanTECH
name=$(basename $0)

usage()
{
	echo "Usage: ${name} only-this-target{0|1} filename(s)-without-.c_extension
 The first parameter should be 0 or 1; 
  0 implies : generate the complete Makefile along with the target(s)
  1 implies : generate only the specific target(s) specified Makefile snippet
 The second parameter onward are the file(s) to generate via make;
  *Ensure that you put only the file(s) name NOT any extension*
"
}

ONLY_TARGET=0
[ $# -lt 2 ] && {
	usage
	exit 1
}
[ "$1" != "0" -a "$1" != "1" ] && {
	usage
	exit 1
}
[ "$1" = "1" ] && ONLY_TARGET=1

# Check all params for a "."
for param in "$@"
do
	if [[ "${param}" = *"."* ]]; then
		echo "*** Error: do Not use any extension or \".\", thank you! ***"
		usage
		exit 1
	fi
done
#echo "num=$#"

# Build list of all targets for the 'ALL' directive
TARGETS=""
i=1
for arg in ${@}
do
	#echo "arg: ${arg}"
	[ ${arg} = "0" ] && continue
	TGT="${arg} ${arg}_dbg ${arg}_dbg_asan ${arg}_dbg_ub ${arg}_dbg_msan"

	[ $# -gt 2 ] && {
		TGT="${TGT} \\"
	}

	[ $i -eq 1 ] && {
	TARGETS="${TARGETS} ${TGT}"
	} || {
	TARGETS="${TARGETS}
	${TGT}"
	}
	let i=i+1
done

OPTZ_LEVEL=2
  # can use 0, 1, 2, 3 or s

# Makefile beginning
MVARS_TOP="# Makefile
#----------------------------------------------------------------------
#  Generated by the genmk.sh utility; one of the \"useful snips\" within
#  this collection: https://github.com/kaiwan/usefulsnips
#
#  ASSUMPTIONS ::
#   1. the convenience files [../]../common.h and [../]../common.c
#      are present
#   2. the clang/LLVM compiler is installed
#   3. the indent(1L) utility is installed
#
#   WARNING! Do NOT start a source filename with 'core' !
#       (will get Erased when 'make clean' is performed).
#
#  (c) Kaiwan NB, kaiwanTECH
#  License: MIT
#----------------------------------------------------------------------
## Pl check and keep or remove <foo>_dbg_[asan|ub|msan] targets
## as desired.
ALL := ${TARGETS}

CC=\${CROSS_COMPILE}gcc
CL=\${CROSS_COMPILE}clang

CFLAGS=-O${OPTZ_LEVEL} -Wall -UDEBUG
CFLAGS_DBG=-g -ggdb -gdwarf-4 -O0 -Wall -Wextra -DDEBUG
CFLAGS_DBG_ASAN=\${CFLAGS_DBG} -fsanitize=address
CFLAGS_DBG_MSAN=\${CFLAGS_DBG} -fsanitize=memory
CFLAGS_DBG_UB=\${CFLAGS_DBG} -fsanitize=undefined

LINKIN :=
 # user will need to explicitly set libraries to link in as required;
 # f.e. -lrt -pthread

all: \${ALL}
CB_FILES := *.[ch]"

# Check for location of the 'common' files;
#  should be either in ../ or ../../ ; act accordingly
if [ -f ../common.c -a -f ../common.h ] ; then
   COMMONLOC=".."
elif [ -f ../../common.c -a -f ../../common.h ] ; then
   COMMONLOC="../.."
else
   echo "${name}: err2: common.[ch] not found : neither in ../ or ../.. ; aborting."
   exit 1
fi

[ ${ONLY_TARGET} -eq 0 ] && {
	echo "${MVARS_TOP}"
	echo
}

RULE_COMMON="common.o: ${COMMONLOC}/common.c ${COMMONLOC}/common.h
	\${CC} \${CFLAGS} -c ${COMMONLOC}/common.c -o common.o"
RULE_COMMON_DBG="common_dbg.o: ${COMMONLOC}/common.c ${COMMONLOC}/common.h
	\${CC} \${CFLAGS_DBG} -c ${COMMONLOC}/common.c -o common_dbg.o"
RULE_COMMON_DBG_ASAN="common_dbg_asan.o: ${COMMONLOC}/common.c ${COMMONLOC}/common.h
	\${CL} \${CFLAGS_DBG_ASAN} -c ${COMMONLOC}/common.c -o common_dbg_asan.o"
RULE_COMMON_DBG_UB="common_dbg_ub.o: ${COMMONLOC}/common.c ${COMMONLOC}/common.h
	\${CL} \${CFLAGS_DBG_UB} -c ${COMMONLOC}/common.c -o common_dbg_ub.o"
RULE_COMMON_DBG_MSAN="common_dbg_msan.o: ${COMMONLOC}/common.c ${COMMONLOC}/common.h
	\${CL} \${CFLAGS_DBG_MSAN} -c ${COMMONLOC}/common.c -o common_dbg_msan.o"

[ ${ONLY_TARGET} -eq 0 ] && {
	echo "${RULE_COMMON}
${RULE_COMMON_DBG}

 #--- Sanitizers (use clang): common_dbg_*
${RULE_COMMON_DBG_ASAN}
${RULE_COMMON_DBG_UB}
${RULE_COMMON_DBG_MSAN}"
	echo
}

# Makefile body
num=1
for filename in "$@"
do
	#echo "filename = ${filename}"

	[ ${num} -eq 1 ] && {
		let num=num+1
		continue
	}

	RULE="#--- Target :: ${filename}
${filename}.o: ${filename}.c
	\${CC} \${CFLAGS} -c ${filename}.c -o ${filename}.o
${filename}: common.o ${filename}.o
	\${CC} -o ${filename} ${filename}.o common.o \${LINKIN}

${filename}_dbg.o: ${filename}.c
	\${CC} \${CFLAGS_DBG} -c ${filename}.c -o ${filename}_dbg.o
${filename}_dbg: ${filename}_dbg.o common_dbg.o
	\${CC} -o ${filename}_dbg ${filename}_dbg.o common_dbg.o \${LINKIN}

 #--- Sanitizers for ${filename} :: (use clang): <foo>_dbg_[asan|ub|msan]
${filename}_dbg_asan.o: ${filename}.c
	\${CL} \${CFLAGS_DBG_ASAN} -c ${filename}.c -o ${filename}_dbg_asan.o
${filename}_dbg_asan: ${filename}_dbg_asan.o common_dbg_asan.o
	\${CL} \${CFLAGS_DBG_ASAN} -o ${filename}_dbg_asan ${filename}_dbg_asan.o common_dbg_asan.o \${LINKIN}

${filename}_dbg_ub.o: ${filename}.c
	\${CL} \${CFLAGS_DBG_UB} -c ${filename}.c -o ${filename}_dbg_ub.o
${filename}_dbg_ub: ${filename}_dbg_ub.o common_dbg_ub.o
	\${CL} \${CFLAGS_DBG_UB} -o ${filename}_dbg_ub ${filename}_dbg_ub.o common_dbg_ub.o \${LINKIN}

${filename}_dbg_msan.o: ${filename}.c
	\${CL} \${CFLAGS_DBG_MSAN} -c ${filename}.c -o ${filename}_dbg_msan.o
${filename}_dbg_msan: ${filename}_dbg_msan.o common_dbg_msan.o
	\${CL} \${CFLAGS_DBG_MSAN} -o ${filename}_dbg_msan ${filename}_dbg_msan.o common_dbg_msan.o \${LINKIN}"


	echo "${RULE}"
	echo

	let num=num+1
done

# Makefile bottom

echo
MVARS_END="# indent- \"beautifies\" C code into the \"Linux kernel style\".
# (cb = C Beautifier :) )
# Note! original source file(s) is overwritten, so we back it up.
cb: \${CB_FILES}
	mkdir bkp 2> /dev/null; cp -f \${CB_FILES} bkp/
	indent -linux \${CB_FILES}

clean:
	rm -vf \${ALL} core* vgcore* *.o *~"
[ ${ONLY_TARGET} -eq 0 ] && {
	echo "${MVARS_END}"
}

exit 0
