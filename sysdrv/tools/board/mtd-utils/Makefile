
ifeq ($(SYSDRV_PARAM), )
    SYSDRV_PARAM:=../../../Makefile.param
    include $(SYSDRV_PARAM)
endif

export LC_ALL=C
SHELL:=/bin/bash

CURRENT_DIR := $(shell pwd)
PKG_TARBALL := mtd-utils-2.0.1.tar.bz2
PKG_NAME := mtd-utils-2.0.1
PKG_BIN := out

PKG_INSTALL_DIR := $(SYSDRV_DIR_OUT_ROOTFS)
ifeq ($(SYSDRV_BUILD_RECOVERY),y)
PKG_INSTALL_DIR := $(OUTPUT_SYSDRV_RAMDISK_TINY_ROOTFS_DIR)
endif

all:
	@test -f $(PKG_BIN)/flashcp \
		-a -f $(PKG_BIN)/flash_eraseall \
		-a -f $(PKG_BIN)/flash_unlock \
		-a -f $(PKG_BIN)/nandwrite \
		-a -f $(PKG_BIN)/ubidetach \
		-a -f $(PKG_BIN)/ubimkvol \
		-a -f $(PKG_BIN)/ubirmvol \
		-a -f $(PKG_BIN)/flash_erase \
		-a -f $(PKG_BIN)/flash_lock \
		-a -f $(PKG_BIN)/nanddump \
		-a -f $(PKG_BIN)/ubiattach \
		-a -f $(PKG_BIN)/ubiblock \
		-a -f $(PKG_BIN)/ubiformat \
		-a -f $(PKG_BIN)/ubirename \
		-a -f $(PKG_BIN)/ubirsvol || (\
	rm -rf $(CURRENT_DIR)/$(PKG_NAME); \
	tar -xf $(PKG_TARBALL); \
	mkdir -p $(CURRENT_DIR)/$(PKG_NAME)/$(PKG_BIN); \
	mkdir -p $(CURRENT_DIR)/$(PKG_BIN)/usr/bin; \
	pushd $(CURRENT_DIR)/$(PKG_NAME)/; \
		./configure --host=$(SYSDRV_CROSS) --target=$(SYSDRV_CROSS) CFLAGS="$(SYSDRV_CROSS_CFLAGS)" \
			LDFLAGS="$(SYSDRV_CROSS_CFLAGS)" --prefix=$(CURRENT_DIR)/$(PKG_NAME)/$(PKG_BIN) \
			--disable-static --enable-shared \
			--disable-tests --disable-install-tests \
			--without-jffs --without-ubifs \
			--without-xattr ; \
		make -j$(SYSDRV_JOBS) > /dev/null || exit -1; \
		make install > /dev/null; \
	popd; \
	pushd $(CURRENT_DIR)/$(PKG_NAME)/$(PKG_BIN)/sbin/; \
	cp -vfa	\
		flashcp flash_erase flash_eraseall flash_lock flash_unlock \
		nanddump nandwrite \
		ubiattach ubiblock ubidetach ubiformat ubimkvol ubirename ubirmvol ubirsvol \
		$(CURRENT_DIR)/$(PKG_BIN)/usr/bin; \
	popd; )
	$(call MAROC_COPY_PKG_TO_SYSDRV_OUTPUT, $(PKG_INSTALL_DIR), $(CURRENT_DIR)/$(PKG_BIN))

clean: distclean

distclean:
	-rm -rf $(PKG_NAME) $(PKG_BIN)

