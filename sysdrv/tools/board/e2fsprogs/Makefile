
ifeq ($(SYSDRV_PARAM), )
    SYSDRV_PARAM:=../../../Makefile.param
    include $(SYSDRV_PARAM)
endif

export LC_ALL=C
SHELL:=/bin/bash

CURRENT_DIR := $(shell pwd)
PKG_TARBALL := e2fsprogs-1.43.9.tar.xz
PKG_NAME := e2fsprogs-1.43.9
PKG_BIN := out

PKG_INSTALL_DIR := $(SYSDRV_DIR_OUT_ROOTFS)
ifeq ($(SYSDRV_BUILD_RECOVERY),y)
PKG_INSTALL_DIR := $(OUTPUT_SYSDRV_RAMDISK_TINY_ROOTFS_DIR)
endif

all:
	@test -f $(PKG_BIN)/usr/sbin/e2fsck || (\
	rm -rf $(CURRENT_DIR)/$(PKG_NAME); \
	tar -xf $(PKG_TARBALL); \
	mkdir -p $(CURRENT_DIR)/$(PKG_NAME)/$(PKG_BIN); \
	mkdir -p $(CURRENT_DIR)/$(PKG_BIN)/usr/; \
	pushd $(CURRENT_DIR)/$(PKG_NAME)/; \
		./configure --host=$(SYSDRV_CROSS) --target=$(SYSDRV_CROSS) CFLAGS="$(SYSDRV_CROSS_CFLAGS) -Os" \
			LDFLAGS="$(SYSDRV_CROSS_CFLAGS)" --prefix=$(CURRENT_DIR)/$(PKG_BIN) \
			--disable-nls \
			--disable-debugfs --disable-imager --disable-defrag --enable-fsck --enable-resizer \
			--disable-testio-debug --disable-rpath --enable-symlink-install --disable-fuse2fs; \
		make -j$(SYSDRV_JOBS) > /dev/null || exit -1; \
		make install > /dev/null; \
		rm -rf $(CURRENT_DIR)/$(PKG_BIN)/share ; \
		rm -rf $(CURRENT_DIR)/$(PKG_BIN)/lib ; \
		mv $(CURRENT_DIR)/$(PKG_BIN)/bin $(CURRENT_DIR)/$(PKG_BIN)/sbin $(CURRENT_DIR)/$(PKG_BIN)/usr ; \
	popd; )
	@sed -i 's/huge_file,//g' $(CURRENT_DIR)/$(PKG_BIN)/etc/mke2fs.conf;
	$(call MAROC_COPY_PKG_TO_SYSDRV_OUTPUT, $(PKG_INSTALL_DIR), $(PKG_BIN))

clean: distclean

distclean:
	-rm -rf $(PKG_NAME) $(PKG_BIN)

