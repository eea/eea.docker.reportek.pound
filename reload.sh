#!/bin/bash
POUND_BIN='/usr/local/sbin/pound'

exec $POUND_BIN -f /etc/pound/config.cfg
