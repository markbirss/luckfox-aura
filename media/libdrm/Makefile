
ifeq ($(MEDIA_PARAM), )
    MEDIA_PARAM:=../Makefile.param
    include $(MEDIA_PARAM)
endif

export LC_ALL=C
SHELL:=/bin/bash

CURRENT_DIR := $(shell pwd)
PKG_TARBALL := $(wildcard libdrm-2.4.109-$(RK_MEDIA_CROSS).tar)
PKG_BIN ?= out
PKG_TARBALL := $(if $(PKG_TARBALL),$(PKG_TARBALL),$(wildcard libdrm-2.4.120-$(RK_MEDIA_CROSS)))
PKG_NAME := $(patsubst libdrm-%-$(RK_MEDIA_CROSS),libdrm-%,$(patsubst %.tar,%,$(PKG_TARBALL)))

ifeq ($(PKG_BIN),)
$(error ### $(CURRENT_DIR): PKG_BIN is NULL, Please Check !!!)
endif

ifeq ($(CONFIG_LIBDRM),y)
PKG_TARGET := libdrm-build
else ifeq ($(RK_ENABLE_LIBDRM),y)
PKG_TARGET := libdrm-build
endif

all: $(PKG_TARGET)
	@echo "build $(PKG_NAME) done"

libdrm-build:
	@test -f $(CURRENT_DIR)/$(PKG_BIN)/lib/libdrm.so || (\
		rm -rf $(PKG_BIN) && mkdir -p $(PKG_BIN); \
		test -f $(PKG_TARBALL) && tar -xf $(PKG_TARBALL) -C $(PKG_BIN)/; \
		test -d $(PKG_TARBALL) && cp -rfa $(PKG_TARBALL)/* $(PKG_BIN)/; \
		rm -rf $(PKG_BIN)/share; \
	);
	$(call MAROC_COPY_PKG_TO_MEDIA_OUTPUT, $(RK_MEDIA_OUTPUT), $(PKG_BIN))

clean: distclean

distclean:
	-rm -rf $(CURRENT_DIR)/$(PKG_NAME)
	-rm -rf $(CURRENT_DIR)/$(PKG_BIN)

