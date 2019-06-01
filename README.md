# usefulsnips
*Useful snippets of code, scripts, etc*

Just a small collection of scripts, resource files, code snippets, etc 
that I find useful.


| Utility Name             | What it's for                                                                                                                                    |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| .gvimrc                  | startup file: gvim startup file; use the .vimrc as well                                                                                          |
| .vimrc                   | startup file: vim startup file defaults                                                                                                          |
| 0setup.bash              | startup file: an initial shell startup settings file; equiv to a .profile                                                                        |
| alrm.sh                  | shell script: post a message dialog (via zenity) after a given timeout                                                                           |
| color.sh                 | generic bash routines: for color manipulation; setting fg, bg colors, etc                                                                        |
| common.sh                | generic bash routines: lots of useful small and reusable functions                                                                               |
| convenient.c             | generic 'C' userspace functions, small and reusable                                                                                              |
| convenient.h             | generic 'C' kernel and userspace macros, functions, small and reusable; ref: https://kaiwantech.wordpress.com/2014/01/06/a-header-of-convenience/|
| ctemplate.c              | a simple starting 'C' program 'template'
| dot_gdbinit              | GDB: startup file; a few aliases etc
| err_common.sh            | generic bash routines: lots of useful small and reusable functions, mostly for error handling in bash scripts
| execlogger.sh            | log every process exec; wrapper over B Gregg's wonderful execsnoop-perf utility
| gdbline.sh               | GDB: simple tool to extract symbol filenames to use within gdb
| genlkm                   | kernel module: generates a simple LKM (kernel module) 'template' in a given dir, along with a basic Makefile
| genmk.sh                 | build: generate a simple Makefile for a typical 'C' systems application
| git-clone-linux-kernel.sh| kernel: git clone a Linux kernel
| gitlog.sh                | git: show human-readable git log 
| hex2dec                  | binary executable (linux): converts given hex numbers to decimal
| htoprc                   | startup file: for htop(1)
| install_pkg_ubuntu.sh    | shell script: install commonly required packages on an Ubuntu/Debian Linux
| iowaiting                | sys mgmt script: show all tasks that are blocking (waiting) on I/O
| lkm                      | kernel: script: workflow automation; builds and inserts an LKM
| lshosts                  | sys mgmt script: lists all hosts on a given subnet (192.168.0.*); nmap wrapper
| maxrss.sh                | sys mgmt script: show the 5 processes taking the most phy mem
| mkclean                  | build: perform 'make clean' recursively from given starting dir
| monitosys                | sys mgmt script: small GUI for monitoring the system; ref: https://kaiwantech.wordpress.com/2014/01/06/simple-system-monitoring-for-a-linux-desktop/
| netcon_rcv_linux.sh      | sys mgmt script: netconsole: receiver script for Linux
| netcon_rcv_win.bat       | sys mgmt script: netconsole: receiver script for Windows
| netcon_setup.sh          | sys mgmt script: Netconsole setup helper script (Linux)
| prcsmem                  | sys mgmt script: show memory usage for a given process(es); wrapper over smem(8)
| procshow.sh              | sys mgmt script: explores the Linux /proc filesystem
| pst.sh                   | sys mgmt script: Simple but useful wrapper over pstree(1); pass PID to see a particular process's tree
| README.md                | This file! :-)
| restart_lib-Robbins.c    | 'C' lib of routines, mostly from the excellent book 'UNIX System Programming', Robbins & Robbins
| show_dhcp_cli.sh         | sys mgmt script: display all IP and MAC addresses over an interface (def to WiFi); wrapper over arp-scan(1)
| sshconn.sh               | sys mgmt script: wrapper to connect to another system over ssh(1) 
| sys_summary.sh           | sys mgmt script: display system summary
| tags_gen                 | source code: for code browsing, generate cscope(1) and ctags(1) indexes
| ver.sh                   | config: show version info of various- kernel, libraries, sysutils, etc
| whats                    | file util: show some metainfo about the given file
| wifi_AP_see.sh           | sys mgmt script: WiFi: displays all Access Points, their Quality & signal level; simple wrapper over iwlist(8)
| xcc_lkm.sh               | kernel dev: this script generates a Makefile to build the given kernel module (works only for simple cases)
| xplore_fs                | file util: recursively shows (small) file's content, type, etc from given starting dir; v useful to explore parts of sysfs, procfs, etc

 



Also: try pastebinit - will "paste" it's stdin to a pastebin-like website !
 Ubuntu doc: https://help.ubuntu.com/community/Pastebinit
