#!/bin/bash
#
patch -p1 < 0001-tests-meson.build-disable-nouveau-tests-for-static-b.patch
patch -p1 < 0002-modetest-Speed-up-dumping-info.patch
patch -p1 < 0003-HACK-Open-rockchip-drm-device-by-default.patch
patch -p1 < 0004-HACK-Bypass-auth-APIs-by-default.patch
