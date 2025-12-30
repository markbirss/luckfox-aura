
ifeq ($(SYSDRV_PARAM), )
	SYSDRV_PARAM:=../../../Makefile.param
	include $(SYSDRV_PARAM)
endif

export LC_ALL=C
SHELL:=/bin/bash

CURRENT_DIR := $(shell pwd)
PCRE2_PKG_NAME := pcre2-10.45
PCRE2_PKG_TAR := $(PCRE2_PKG_NAME).tar.bz2

PKG_BIN := out

SYSDRV_CROSS_CFLAGS += $(SYSDRV_OPTS) -Os

all:
	$(RKDBG)test -f $(CURRENT_DIR)/$(PKG_BIN)/lib/libpcre2-8.a || ( \
		mkdir -p $(CURRENT_DIR)/$(PKG_BIN); \
		rm -rf $(CURRENT_DIR)/$(PCRE2_PKG_NAME); \
		tar xf $(CURRENT_DIR)/$(PCRE2_PKG_NAME).tar.bz2; \
		cd $(CURRENT_DIR)/$(PCRE2_PKG_NAME); \
		CC=$(SYSDRV_CROSS)-gcc \
		./configure --prefix=$(CURRENT_DIR)/$(PKG_BIN) \
		--enable-shared --enable-static \
		--host $(SYSDRV_CROSS) --target $(SYSDRV_CROSS) || (echo "Configure $(PCRE2_PKG_NAME) failed" && exit 1); \
		make -j$(SYSDRV_JOBS) || ( echo "Make $(PCRE2_PKG_NAME) failed" && exit 1); \
		make install || ( echo "Install $(PCRE2_PKG_NAME) failed" && exit 1); \
		rm -rf $(CURRENT_DIR)/$(PKG_BIN)/{bin,share}; \
		)
	$(RKDBG)echo "build dependent libs done"
	$(call MAROC_COPY_PKG_TO_SYSDRV_OUTPUT, $(SYSDRV_DIR_OUT_ROOTFS), $(PKG_BIN))

clean: distclean

distclean:
	-rm -rf $(PCRE2_PKG_NAME) $(PKG_BIN)
