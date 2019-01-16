#!/bin/bash
# genlkm
# Generate a simple LKM 'template'
# (c) 2019 Kaiwan N Billimoria, kaiwanTECH
name=$(basename $0)

usage()
{
	echo "Usage: ${name} filename-without-.c_extension"
}

ONLY_TARGET=0
[ $# -lt 1 ] && {
	usage
	exit 1
}

# Check all params for a "."
for param in "$@"
do
	if [[ "${param}" = *"."* ]]; then
		echo "*** Error: do Not use any extension or \".\", thank you! ***"
		usage
		exit 1
	fi
done


#------------- File Sections ------------------------
HDR_1="/*
 * $1.c
 ***************************************************************
 * This program is part of the source code released for the book
 *  \"Linux Kernel Development Cookbook\"
 *  (c) Author: Kaiwan N Billimoria
 *  Publisher:  Packt
 *  GitHub repository:
 *  https://github.com/PacktPublishing/Linux-Kernel-Development-Cookbook
 *
 * From: Ch : 
 ****************************************************************
 * Brief Description:
 *
 * For details, please refer the book, Ch .
 */
"

INC_1="
#include <linux/init.h>
#include <linux/module.h>
"

MAC_1="
#define OURMODNAME   \"$1\"
"

MOD_STUFF="
MODULE_AUTHOR(\"<insert your name here>\");
MODULE_DESCRIPTION(\"LKDC book:ch/: hello, world\");
MODULE_LICENSE(\"Dual MIT/GPL\");
MODULE_VERSION(\"0.1\");
"

CODE_1="
static int __init $1_init(void)
{
	pr_info(\"%s: inserted\n\", OURMODNAME);
	return 0;		/* success */
}

static void __exit $1_exit(void)
{
	pr_info(\"%s: done\n\", OURMODNAME);
}

module_init($1_init);
module_exit($1_exit);
"

[ -f $1.c ] && cp -f $1.c $1.c.bkp
cat > $1.c << EOF
${HDR_1}
${INC_1}
${MAC_1}
${MOD_STUFF}
${CODE_1}
EOF

echo "[+] LKM $1.c generated"
ls -l $1.c

echo "[+] Generating the Makefile for $1.c ..."
xcc_lkm.sh $1

