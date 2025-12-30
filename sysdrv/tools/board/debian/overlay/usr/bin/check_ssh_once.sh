#!/usr/bin/env bash

sleep 5

if ! systemctl is-active --quie ssh; then
	systemctl restart ssh
fi
t
