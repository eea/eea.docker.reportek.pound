#!/bin/bash
POUND_BIN='/opt/pound/sbin/pound'

exec $POUND_BIN -f /opt/pound/etc/config.cfg
