#!/bin/bash -e

if [ ! $RELEASE ]; then
	RELEASE='trixie'
fi

./mk-rootfs-$RELEASE.sh
