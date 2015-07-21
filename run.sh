#!/bin/bash
set -x

CONFIG_FILE='/etc/pound/config.cfg'
PARAMS="-f $CONFIG_FILE"

if [ -f "$CONFIG_FILE" ]; then
  echo 'Using mounted config file'
else
  echo 'User "pound"' > $CONFIG_FILE
  echo 'Group "pound"' >> $CONFIG_FILE
  echo 'Daemon 0' >> $CONFIG_FILE
  echo 'LogLevel 3' >> $CONFIG_FILE
  echo 'LogFacility local1' >> $CONFIG_FILE

  if [ ! -z "$ALIVE" ]; then echo "Alive $ALIVE" >> $CONFIG_FILE; fi
  if [ ! -z "$CLIENT" ]; then echo "Client $CLIENT" >> $CONFIG_FILE; fi
  if [ ! -z "$TIMEOUT" ]; then echo "TimeOut $TIMEOUT" >> $CONFIG_FILE; fi
  echo 'ListenHTTP' >> $CONFIG_FILE
  echo 'Address 0.0.0.0' >> $CONFIG_FILE
  echo 'Port 80' >> $CONFIG_FILE
  echo 'End' >> $CONFIG_FILE
  echo 'Service' >> $CONFIG_FILE

  if [ ! -z "$BACKENDS" ]; then
    for BACKEND in $(echo "$BACKENDS" | tr ' ' '\n'); do
      echo 'Backend' >> $CONFIG_FILE
      IFS=':' read -a address <<< "$BACKEND"
      echo "Address ${address[0]}" >> $CONFIG_FILE
      echo "Port ${address[1]}" >> $CONFIG_FILE
      echo 'End' >> $CONFIG_FILE
    done
  echo 'End' >> $CONFIG_FILE
  # FIXME: treat case  when no BACKENDS are available in env
fi

/usr/local/sbin/pound $PARAMS
