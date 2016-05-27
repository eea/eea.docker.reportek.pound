#!/bin/bash

IPS_1=`cat /opt/dns.backends`
python3 /opt/configure.py dns | j2 --format=json /opt/pound/etc/backends.j2 > /opt/pound/etc/backends.cfg
IPS_2=`cat /opt/dns.backends`

if [ "$IPS_1" != "$IPS_2" ]; then
  echo "DNS backends changed: $IPS_2"
  /opt/reload.sh
fi

