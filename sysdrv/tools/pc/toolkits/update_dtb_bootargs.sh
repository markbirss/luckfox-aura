#!/bin/bash
#
# SET ANSI COLORS {{{ START
C_RED="[1;31m"
C_CYAN="[1;36m"
C_BLUE="[1;34m"
C_GREEN="[1;32m"
C_WHITE="[1;37m"
C_YELLOW="[1;33m"
C_MAGENTA="[1;35m"
C_NORMAL="[0;39m"
# SET ANSI COLORS END }}}

set -e
cmd=`realpath $0`
cwd=`dirname $cmd`
CMD_VERSION=1.0.0

function msg_dbg()
{
	if [ "$RK_DEBUG" != "1" ]; then
		return
	fi
	echo -e "${C_CYAN}[$(basename $0):info] $*${C_NORMAL}" >&2
}

function msg_info()
{
	echo -e "${C_GREEN}[$(basename $0):info] $1${C_NORMAL}" >&2
}

function msg_warn()
{
	echo -e "${C_YELLOW}[$(basename $0):warn] $1${C_NORMAL}" >&2
}

function msg_error()
{
	echo -e "${C_RED}[$(basename $0):error] $1${C_NORMAL}" >&2
}

function msg_help()
{
	echo "command format:"
	echo "    `basename $cmd` -v  -h --cmdline --output --dtb"
	echo "        -v|--version      (Optional) view this version."
	echo "        -h|--help         (Optional) view this help message."
	echo "        --dtb             (MUST) input dtb file path."
	echo "        --cmdline         (MUST) input strings which update into kernel's cmdline."
	echo "        --append-bootargs (Optional) the flag to append bootargs."
	echo "        --output          (MUST) output file path."
	return
}

function chk_param()
{
	local cnt
	cnt=0
	while [ $# -ne 0 ]
	do
		case $1 in
			-v|--version)
				msg_info "V$CMD_VERSION"
				exit 0
				;;
			-h|--help)
				msg_help
				exit 0
				;;
			--cmdline)
				PARAM_CMDLINE=$2
				cnt=$(( cnt + 1 ))
				while [ -n "$3" ]
				do
					case $3 in
						--*)
							break
							;;
						*)
							PARAM_CMDLINE="$PARAM_CMDLINE $3"
							;;
					esac
					shift
				done
				;;
			--output)
				PARAM_OUTPUT_PATH=$2
				cnt=$(( cnt + 1 ))
				;;
			--dtb)
				PARAM_DTB_PATH=$2
				cnt=$(( cnt + 1 ))
				;;
			--append-bootargs)
				FLAG_APPEND_BOOTARGS="YES"
				;;
			*)
				;;
		esac
		shift
	done

	if [ $cnt -ne 3 \
		-o ! -f "$PARAM_DTB_PATH" \
		-o -z "$PARAM_OUTPUT_PATH" ]; then
		msg_error "Invalid parameter..."
		if [ ! -f "$PARAM_DTB_PATH" ];then
			msg_error "Not found file: $PARAM_DTB_PATH"
		fi
		msg_help
		exit -1
	fi

	if [ -z "$PARAM_CMDLINE" ];then
		msg_warn "parameter --cmdline is NULL, nothing to be done"
		exit 0
	fi
}

function get_dtb_param() {
	local local_dump_dtb
	local tmp_ramdisk

	if [ ! -f "${1}" ]; then
		echo "Not found ${1} ignore"
		return
	fi
	local_dump_dtb=${1}

	# ramdisk_c=`grep -A 3 -e ramdisk_c $local_dump_dtb | grep -w "reg"|awk -F\< '{print $2}'|awk '{print $1}'`
	# ramdisk_c_size=`grep -A 3 -e ramdisk_c  $local_dump_dtb |grep reg|awk -F\< '{print $2}'|awk '{print $2}' | awk -F\> '{print $1}'`

	ramdisk_r_size=`grep -A 3 ramdisk_r $local_dump_dtb |grep reg|awk -F\< '{print $2}'|awk '{print $2}' | awk -F\> '{print $1}'`
	ramdisk_r=`grep -A 3 ramdisk_r $local_dump_dtb |grep reg|awk -F\< '{print $2}'|awk '{print $1}'`
}
################################################################################
# Start
################################################################################
dtc --version &>/dev/null
if [ "$?" -ne 0 ]; then
	msg_error "No found dtc tool, please install it. (run \"sudo apt-get install device-tree-compile\")"
	return
fi

PARAM_DTB_PATH=""
PARAM_CMDLINE=""
PARAM_OUTPUT_PATH=""
FLAG_APPEND_BOOTARGS=""

chk_param $@

ramdisk_r="NONE"
# ramdisk_c="NONE"
# ramdisk_c_size="NONE"
ramdisk_r_size="NONE"

msg_info "PARAM_DTB_PATH = $PARAM_DTB_PATH"
msg_info "PARAM_CMDLINE = $PARAM_CMDLINE"
msg_info "PARAM_OUTPUT_PATH = $PARAM_OUTPUT_PATH"

__workdir=$(dirname $PARAM_OUTPUT_PATH)/.update_dtb_workdir
rm -rf $__workdir
mkdir -p $__workdir
cp -f $PARAM_DTB_PATH $__workdir/fdt

dump_kernel_dtb_file=${__workdir}/fdt.dump.dts
dtc -I dtb -O dts -o ${dump_kernel_dtb_file} $__workdir/fdt 2>/dev/null

if [ "$FLAG_APPEND_BOOTARGS" = "YES" ];then
	get_dtb_param ${dump_kernel_dtb_file}
	if [ "$PARAM_CMDLINE" = "initrd" ];then
		PARAM_CMDLINE="${PARAM_CMDLINE}=${ramdisk_r},${ramdisk_r_size}"
	fi
	msg_info "Append ${PARAM_CMDLINE} into kernel.dts bootargs"
else

if cat $dump_kernel_dtb_file |grep "bootargs = " \
	| grep -w -e 'rootfstype=erofs' -e 'root=/dev/rd0' &>/dev/null;then
	msg_info "Ignore rootfstype=erofs or root=/dev/rd0"
else
	sed -i -e 's/\(bootargs = "\)\(.*\)\(root=[0-9a-zA-Z\/:_]\+[^ ]\)\(.*\)"/\1\2\4"/g' \
		-e 's/\(bootargs = "\)\(.*\)\(rootfstype=[0-9a-zA-Z]\+[^ ]\)\(.*\)"/\1\2\4"/g' \
		$dump_kernel_dtb_file
fi

sed -i -e 's/\(bootargs = "\)\(.*\)\(ubi.mtd==[0-9]\+[^ ]\)\(.*\)"/\1\2\4"/g' \
	-e 's/\(bootargs = "\)\(.*\)\(ubi.block=0,rootfs \)\(.*\)"/\1\2\4"/g' \
	-e 's/\(bootargs = "\)\(.*\)\(mtdparts=[0-9a-zA-Z:@,(_)]\+[^ ]\)\(.*\)"/\1\2\4"/g' \
	-e 's/\(bootargs = "\)\(.*\)\(blkdevparts=[0-9a-zA-Z:@,(_)]\+[^ ]\)\(.*\)"/\1\2\4"/g' \
	-e 's/\(bootargs = "\)\(.*\)\(rk_dma_heap_cma=[0-9a-zA-Z]\+[^ ]\)\(.*\)"/\1\2\4"/g' $dump_kernel_dtb_file

fi

sed_cmd="sed -i -e 's/\(bootargs = \"\)\(.*\)\"/\1\2 ${PARAM_CMDLINE////\\/}\"/g' $dump_kernel_dtb_file"
msg_dbg $sed_cmd
eval $sed_cmd
dtc -I dts -O dtb -o ${PARAM_OUTPUT_PATH} $dump_kernel_dtb_file 2>/dev/null

if [ "$RK_DEBUG" != "1" ]; then
	rm -rf $__workdir
fi
