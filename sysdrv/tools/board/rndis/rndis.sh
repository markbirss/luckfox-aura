#!/bin/sh

if [ "$1" = "adb_on" ];then
ADB_EN=on
else
ADB_EN=off
fi
USB_FUNCTIONS_DIR=/sys/kernel/config/usb_gadget/rockchip/functions
USB_CONFIGS_DIR=/sys/kernel/config/usb_gadget/rockchip/configs/b.1


##main
#init usb config

cd /oem/usr/ko
test ! -f configfs.ko                    || insmod configfs.ko
test ! -f usb-common.ko                  || insmod usb-common.ko
test ! -f udc-core.ko                    || insmod udc-core.ko
test ! -f libcomposite.ko                || insmod libcomposite.ko
test ! -f usbcore.ko                     || insmod usbcore.ko
test ! -f usb_f_fs.ko                    || insmod usb_f_fs.ko
test ! -f phy-rockchip-naneng-combphy.ko || insmod phy-rockchip-naneng-combphy.ko
test ! -f phy-rockchip-inno-usb2.ko      || insmod phy-rockchip-inno-usb2.ko
test ! -f xhci-hcd.ko                    || insmod xhci-hcd.ko
test ! -f ohci-hcd.ko                    || insmod ohci-hcd.ko
test ! -f xhci-plat-hcd.ko               || insmod xhci-plat-hcd.ko
test ! -f u_ether.ko                     || insmod u_ether.ko
test ! -f roles.ko                       || insmod roles.ko
test ! -f ohci-platform.ko               || insmod ohci-platform.ko
test ! -f dwc3.ko                        || insmod dwc3.ko
test ! -f dwc3-of-simple.ko              || insmod dwc3-of-simple.ko
test ! -f hid.ko                         || insmod hid.ko
test ! -f hid-generic.ko                 || insmod hid-generic.ko
test ! -f usbhid.ko                      || insmod usbhid.ko
test ! -f ehci-hcd.ko                    || insmod ehci-hcd.ko
test ! -f ehci-platform.ko               || insmod ehci-platform.ko
test ! -f videobuf2-dma-sg.ko            || insmod videobuf2-dma-sg.ko
test ! -f usb_f_rndis.ko                 || insmod usb_f_rndis.ko
test ! -f usb_f_uvc.ko                   || insmod usb_f_uvc.ko
test ! -f usb_f_hid.ko                   || insmod usb_f_hid.ko
test ! -f u_audio.ko                     || insmod u_audio.ko
test ! -f usb_f_uac1.ko                  || insmod usb_f_uac1.ko
test ! -f usb_f_uac2.ko                  || insmod usb_f_uac2.ko

mkdir /dev/usb-ffs
if cat /proc/mounts |grep "/sys/kernel/config"; then
	echo "configfs already mounted"
else
	mount -t configfs none /sys/kernel/config
fi
mkdir -p /sys/kernel/config/usb_gadget/rockchip
mkdir -p /sys/kernel/config/usb_gadget/rockchip/strings/0x409
mkdir -p ${USB_CONFIGS_DIR}/strings/0x409
echo 0x2207 > /sys/kernel/config/usb_gadget/rockchip/idVendor
echo 0x0310 > /sys/kernel/config/usb_gadget/rockchip/bcdDevice
echo 0x0200 > /sys/kernel/config/usb_gadget/rockchip/bcdUSB
echo 239 > /sys/kernel/config/usb_gadget/rockchip/bDeviceClass
echo 2 > /sys/kernel/config/usb_gadget/rockchip/bDeviceSubClass
echo 1 > /sys/kernel/config/usb_gadget/rockchip/bDeviceProtocol
SERIAL_NUM=`cat /proc/cpuinfo | grep Serial | awk '{print $3}'`
if [ -z $SERIAL_NUM -o "$SERIAL_NUM" = "0" ];then
	if [ -f "/sys/class/net/eth0/address" ];then
		SERIAL_NUM=$(cat /sys/class/net/eth0/address| md5sum)
	else
		SERIAL_NUM=$(echo $RANDOM| md5sum)
	fi
	SERIAL_NUM=${SERIAL_NUM:0:16}
fi
echo "serialnumber is $SERIAL_NUM"
echo $SERIAL_NUM > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/serialnumber
echo "rockchip" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/manufacturer
echo "UVC" > /sys/kernel/config/usb_gadget/rockchip/strings/0x409/product
echo 0x1 > /sys/kernel/config/usb_gadget/rockchip/os_desc/b_vendor_code
echo "MSFT100" > /sys/kernel/config/usb_gadget/rockchip/os_desc/qw_sign
echo 500 > /sys/kernel/config/usb_gadget/rockchip/configs/b.1/MaxPower
#ln -s /sys/kernel/config/usb_gadget/rockchip/configs/b.1 /sys/kernel/config/usb_gadget/rockchip/os_desc/b.1
echo 0x0016 > /sys/kernel/config/usb_gadget/rockchip/idProduct

##reset config,del default adb config
if [ -e ${USB_CONFIGS_DIR}/ffs.adb ]; then
	#for rk1808 kernel 4.4
	rm -f ${USB_CONFIGS_DIR}/ffs.adb
else
	ls ${USB_CONFIGS_DIR} | grep f[0-9] | xargs -I {} rm ${USB_CONFIGS_DIR}/{}
fi

mkdir /sys/kernel/config/usb_gadget/rockchip/functions/rndis.gs0
echo "rndis" > ${USB_CONFIGS_DIR}/strings/0x409/configuration
ln -s ${USB_FUNCTIONS_DIR}/rndis.gs0 ${USB_CONFIGS_DIR}/f1

if [ "$ADB_EN" = "on" ];then
	if [ -f "/usr/bin/adbd" ];then
		killall adbd || kill `ps |grep -v grep |grep adbd|awk '{print $1}'` || echo "error: kill adbd failed"
		ifconfig lo up
		mkdir ${USB_FUNCTIONS_DIR}/ffs.adb
		CONFIG_STR=`cat /sys/kernel/config/usb_gadget/rockchip/configs/b.1/strings/0x409/configuration`
		STR=${CONFIG_STR}_adb
		echo $STR > ${USB_CONFIGS_DIR}/strings/0x409/configuration
		USB_CNT=`echo $STR | awk -F"_" '{print NF-1}'`
		let USB_CNT=USB_CNT+1
		echo "adb on++++++ ${USB_CNT}"
		ln -s ${USB_FUNCTIONS_DIR}/ffs.adb ${USB_CONFIGS_DIR}/f${USB_CNT}
		umount /dev/usb-ffs/adb
		mkdir -p /dev/usb-ffs/adb -m 0770
		mount -o uid=2000,gid=2000 -t functionfs adb /dev/usb-ffs/adb
		start-stop-daemon --start --quiet --background --exec /usr/bin/adbd
		sleep .5
	else
		echo "error: adbd not exist"
	fi
fi

sleep 1
UDC=`ls /sys/class/udc/| awk '{print $1}'`
echo $UDC > /sys/kernel/config/usb_gadget/rockchip/UDC

#sleep 1
echo "config usb0 IP..."
ifconfig usb0 192.168.1.100
ifconfig usb0 up
