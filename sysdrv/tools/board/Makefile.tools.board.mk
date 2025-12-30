
ifeq ($(ENABLE_WIFI),y)
__sysdrv_tools_board_build__ += board-build-pcre2 board-build-openssl
endif
ifeq ($(ENABLE_ADBD),y)
__sysdrv_tools_board_build__ += board-build-openssl
endif
ifeq ($(ENABLE_OTA),y)
__sysdrv_tools_board_build__ += board-build-openssl
endif
ifeq ($(ENABLE_WEB_BACKEND),y)
__sysdrv_tools_board_build__ += board-build-pcre2 board-build-openssl
endif
ifeq ($(ENABLE_STRACE),y)
__sysdrv_tools_board_build__ += board-build-strace
endif
tools_board-builds: \
		$(__sysdrv_tools_board_build__) \
		board-build-toolkits \
		board-build-gdb \
		board-build-eudev \
		board-build-rndis \
		board-build-adbd \
		board-build-rk_ota \
		board-build-rockchip_test \
		board-build-e2fsprogs \
		board-build-sysstat \
		board-build-fio \
		board-build-i2c_tools \
		board-build-dosfstools \
		board-build-exfatprogs \
		board-build-lrzsz \
		board-build-mtd_utils \
		board-build-strace
	@echo "build tools board done"

tools_board-clean:
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/e2fsprogs distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/mtd-utils distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/android-tools distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/eudev distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/toolkits distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/gdb distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/memtester distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/stressapptest distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/rk_ota distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/sysstat distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/fio distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/rockchip_test distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/rndis distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/i2c-tools distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/dosfstools distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/exfatprogs distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/lrzsz distclean
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/strace distclean

board-build-toolkits:
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/toolkits

board-build-gdb:
ifeq ($(ENABLE_GDB),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/gdb;
endif

board-build-eudev:
ifeq ($(ENABLE_EUDEV),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/eudev;
endif

board-build-rndis:
ifeq ($(ENABLE_RNDIS),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/rndis;
endif

board-build-adbd:
ifeq ($(ENABLE_ADBD),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/android-tools
endif

board-build-rk_ota:
ifeq ($(ENABLE_OTA),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/rk_ota
endif

board-build-rockchip_test:
ifeq ($(ENABLE_ROCKCHIP_TEST),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/rockchip_test
endif

board-build-e2fsprogs:
ifneq ($(findstring $(BOOT_MEDIUM),emmc ufs),)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/e2fsprogs
endif

board-build-mtd_utils:
ifneq ($(findstring $(BOOT_MEDIUM),spi_nand slc_nand spi_nor),)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/mtd-utils
ifeq ($(BOOT_MEDIUM),spi_nor)
ifeq ($(RK_SYSDRV_CHIP),rv1106)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/idb_bootconfig
endif
	@pushd $(SYSDRV_DIR_OUT_ROOTFS)/usr/bin; \
		rm -f nanddump nandwrite \
			ubiattach ubiblock ubidetach ubiformat \
			ubimkvol ubirename ubirmvol ubirsvol; \
	popd;
endif
endif
board-build-sysstat:
ifeq ($(ENABLE_SYSSTAT),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/sysstat
endif

board-build-fio:
ifeq ($(ENABLE_FIO),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/fio
endif

board-build-i2c_tools:
ifeq ($(ENABLE_I2C_TOOLS),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/i2c-tools
endif

board-build-dosfstools:
ifeq ($(ENABLE_DOSFSTOOLS),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/dosfstools;
endif

board-build-exfatprogs:
ifeq ($(ENABLE_EXFATPROGS),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/exfatprogs;
endif

board-build-strace:
ifeq ($(ENABLE_STRACE),y)
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/strace;
endif

board-build-lrzsz:
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/lrzsz;

board-build-pcre2:
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/pcre2;

board-build-openssl:
	$(MAKE) -C $(SYSDRV_DIR)/tools/board/toolkits/openssl;
