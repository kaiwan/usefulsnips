#!/bin/bash
# genmk
# generate Makefile rules for the book src..
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

#[ -f Makefile ] && ALL_LINE=$(grep "ALL *\:=" Makefile)

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

# Makefile beginning
MVARS_TOP="# Makefile
#----------------------------------------------------------------------
#  Generated by the genmk.sh utility.
#
#  ASSUMPTION :: the convenience files ../common.h and ../common.c
#   are present.
#
#  (c) Kaiwan NB, kaiwanTECH
#  License: MIT
#----------------------------------------------------------------------

## Pl check and keep or remove <foo>_dbg_[asan|ub|msan] targets
## as desired.
ALL := ${TARGETS}

CC=\${CROSS_COMPILE}gcc
CL=\${CROSS_COMPILE}clang

CFLAGS=-Wall
CFLAGS_DBG=-g -ggdb -gdwarf-4 -O0 -Wall -Wextra -fPIC
CFLAGS_DBG_ASAN=\${CFLAGS_DBG} -fsanitize=address
CFLAGS_DBG_MSAN=\${CFLAGS_DBG} -fsanitize=memory #-fPIE -pie
CFLAGS_DBG_UB=\${CFLAGS_DBG} -fsanitize=undefined

all: \${ALL}
CB_FILES := *.[ch]"

[ ${ONLY_TARGET} -eq 0 ] && {
	echo "${MVARS_TOP}"
	echo
}

RULE="common.o: ../common.c ../common.h
	\${CC} \${CFLAGS} -c ../common.c -o common.o
common_dbg.o: ../common.c ../common.h
	\${CC} \${CFLAGS_DBG} -c ../common.c -o common_dbg.o"
[ ${ONLY_TARGET} -eq 0 ] && {
	echo "${RULE}"
	echo
}

# Makefile body
num=1
for rulename in "$@"
do
	#echo "rulename = ${rulename}"

	[ ${num} -eq 1 ] && {
		let num=num+1
		continue
	}
	#[ ${num} -ge $# ] && break

	# TODO : don't repeat the common_dbg_* rules when >1 targets 

	RULE="${rulename}.o:
	\${CC} \${CFLAGS} -c ${rulename}.c -o ${rulename}.o
${rulename}: common.o ${rulename}.o
	\${CC} \${CFLAGS} -o ${rulename} ${rulename}.o common.o

${rulename}_dbg.o: ${rulename}.c
	\${CC} \${CFLAGS_DBG} -c ${rulename}.c -o ${rulename}_dbg.o
	\${CL} \${CFLAGS_DBG_ASAN} -c ${rulename}.c -o ${rulename}_dbg_asan.o
	\${CL} \${CFLAGS_DBG_UB} -c ${rulename}.c -o ${rulename}_dbg_ub.o
	\${CL} \${CFLAGS_DBG_MSAN} -c ${rulename}.c -o ${rulename}_dbg_msan.o

${rulename}_dbg: ${rulename}_dbg.o common_dbg.o
	\${CC} \${CFLAGS_DBG} -o ${rulename}_dbg ${rulename}_dbg.o common_dbg.o

common_dbg_asan.o: ../common.c ../common.h
	\${CL} \${CFLAGS_DBG_ASAN} -c ../common.c -o common_dbg_asan.o
${rulename}_dbg_asan.o: common_dbg_asan.o
	\${CL} \${CFLAGS_DBG_ASAN} -c ${rulename}.c -o ${rulename}_dbg_asan.o common_dbg_asan.o
${rulename}_dbg_asan: ${rulename}_dbg_asan.o common_dbg_asan.o
	\${CL} \${CFLAGS_DBG_ASAN} -o ${rulename}_dbg_asan ${rulename}_dbg_asan.o common_dbg_asan.o

common_dbg_ub.o: ../common.c ../common.h
	\${CL} \${CFLAGS_DBG_UB} -c ../common.c -o common_dbg_ub.o
${rulename}_dbg_ub.o: common_dbg_ub.o
	\${CL} \${CFLAGS_DBG_UB} -c ${rulename}.c -o ${rulename}_dbg_ub.o common_dbg_ub.o
${rulename}_dbg_ub: ${rulename}_dbg_ub.o common_dbg_ub.o
	\${CL} \${CFLAGS_DBG_UB} -o ${rulename}_dbg_ub ${rulename}_dbg_ub.o common_dbg_ub.o

common_dbg_msan.o: ../common.c ../common.h
	\${CL} \${CFLAGS_DBG_MSAN} -c ../common.c -o common_dbg_msan.o
${rulename}_dbg_msan.o: common_dbg_msan.o
	\${CL} \${CFLAGS_DBG_MSAN} -c ${rulename}.c -o ${rulename}_dbg_msan.o common_dbg_msan.o
${rulename}_dbg_msan: ${rulename}_dbg_msan.o common_dbg_msan.o
	\${CL} \${CFLAGS_DBG_MSAN} -o ${rulename}_dbg_msan ${rulename}_dbg_msan.o common_dbg_msan.o"


	echo "${RULE}"
	echo

	let num=num+1
done

# Makefile bottom

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
