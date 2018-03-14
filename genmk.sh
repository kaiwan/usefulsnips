#!/bin/bash
# genmk
# generate Makefile rules for the given src file
# (c) kaiwan n billimoria, kaiwanTECH
name=$(basename $0)
[ $# -lt 1 ] && {
	echo "Usage: ${name} filename-without-.c_extension"
	exit 1
}
extn=${1:(-2)}
#echo "extn = ${extn}"
[ "${extn}" = ".c" ] && {
	echo "Usage: ${name} filename ONLY (do NOT put the .c)"
	exit 1
}

# Makefile beginning
MVARS_TOP="CC=\${CROSS_COMPILE}gcc
CL=\${CROSS_COMPILE}clang

CFLAGS=-Wall
CFLAGS_DBG=-g -ggdb -gdwarf-4 -O0 -Wall -Wextra
CFLAGS_DBG_ASAN=${CFLAGS_DBG} -fsanitize=address
CFLAGS_DBG_UB=${CFLAGS_DBG} -fsanitize=undefined

all: \${ALL}
CB_FILES := *.[ch]
"

echo "${MVARS_TOP}"
echo

###
# Assumption:: we have the files ../common.[ch]
###

RULE="common.o: ../common.c ../common.h
	\${CC} \${CFLAGS} -c ../common.c -o common.o
common_dbg.o: ../common.c ../common.h
	\${CC} \${CFLAGS_DBG} -c ../common.c -o common_dbg.o"
echo "${RULE}"
echo

# Makefile body
for rulename in "$@"
do
	#echo "rulename = ${rulename}"

	RULE="
${rulename}: common.o ${rulename}.o
	\${CC} \${CFLAGS} -o ${rulename} ${rulename}.c common.o
${rulename}_dbg.o: ${rulename}.c
	\${CC} \${CFLAGS_DBG} -c ${rulename}.c -o ${rulename}_dbg.o
${rulename}_dbg: ${rulename}_dbg.o common_dbg.o
	\${CC} -o ${rulename}_dbg ${rulename}_dbg.o common_dbg.o"

	RULE_SANITZ="
	\${CL} \${CFLAGS_DBG_ASAN} -o ${rulename}_asan ${rulename}_dbg.o common_dbg.o
	\${CL} \${CFLAGS_DBG_UB} -o ${rulename}_ub ${rulename}_dbg.o common_dbg.o
	\${CL} \${CFLAGS_DBG_MSAN} -o ${rulename}_msan ${rulename}_dbg.o common_dbg.o"

	echo "${RULE}${RULE_SANITZ}"
	echo
done

# Makefile bottom

MVARS_END="# indent- \"beautifies\" C code into the \"Linux kernel style\"\.
# (cb = C Beautifier :) )
# Note! original source file(s) is overwritten, so we back it up.
cb: \${CB_FILES}
	mkdir bkp 2> /dev/null; cp -f \${CB_FILES} bkp/
	indent -linux \${CB_FILES}

clean:
	rm -vf \${ALL} core* vgcore* *.o *~"
echo "${MVARS_END}"

exit 0
