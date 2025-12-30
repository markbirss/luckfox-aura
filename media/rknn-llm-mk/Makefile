
ifeq ($(MEDIA_PARAM), )
    MEDIA_PARAM:=../Makefile.param
    include $(MEDIA_PARAM)
endif

export LC_ALL=C
SHELL:=/bin/bash

CURRENT_DIR := $(shell pwd)
PKG_NAME := rknn-llm
PKG_BIN ?= out

ifeq ($(RK_MEDIA_ARCH_TYPE),arm64)
PKG_ARCH := aarch64
endif

ifeq ($(RK_MEDIA_ARCH_TYPE),arm)
PKG_ARCH := armhf
endif

ifeq ($(CONFIG_RK_NPU_RUNTIME),y)
PKG_TARGET += rknn-llm-build
endif

ifeq ($(PKG_ARCH),)
$(error *** $(PKG_NAME) not support $(RK_MEDIA_ARCH_TYPE) ***)
endif

all: $(PKG_TARGET)
	@echo "build $(PKG_NAME) done";

rknn-llm-build:
	@mkdir -p $(CURRENT_DIR)/$(PKG_BIN)/{lib,include/rkllm}
	@cp -r $(CURRENT_DIR)/$(PKG_NAME)/rkllm-runtime/Linux/librkllm_api/$(PKG_ARCH)/* $(CURRENT_DIR)/$(PKG_BIN)/lib
	@cp -rf $(CURRENT_DIR)/$(PKG_NAME)/rkllm-runtime/Linux/librkllm_api/include/* $(CURRENT_DIR)/$(PKG_BIN)/include/rkllm
	@$(call MAROC_COPY_PKG_TO_MEDIA_OUTPUT, $(RK_MEDIA_OUTPUT), $(PKG_BIN))

clean:
	@rm -rf $(PKG_BIN)

distclean: clean
