#!/bin/bash
set -x

CONFIG_FILE='/etc/pound/config.cfg'
POUND_BIN='/usr/local/sbin/pound'
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
  elif tail -n +2 /etc/hosts | grep -vqE '::|localhost'; then
    tail -n +2  /etc/hosts | grep -vE '::|localhost' | cut -f 1 | sort | uniq | while read ip; do
      echo 'Backend' >> $CONFIG_FILE
      echo "Address $ip" >> $CONFIG_FILE
      echo "Port 80" >> $CONFIG_FILE
      echo 'End' >> $CONFIG_FILE
    done
  fi
  if [ ! -z "$STICKY" ]; then
    echo 'Session' >> $CONFIG_FILE;
    if [ -z "$SESSIONTYPE" ]; then
      echo 'Type COOKIE' >> $CONFIG_FILE;
    elif [ ! -z "$SESSIONTYPE" ]; then
      echo "Type $SESSIONTYPE" >> $CONFIG_FILE;
    fi
    if [ -z "$SESSIONCOOKIE" ]; then
      echo 'ID "__ac"' >> $CONFIG_FILE;
    elif [ ! -z "$SESSIONCOOKIE" ]; then
      echo "ID \"$SESSIONCOOKIE\"" >> $CONFIG_FILE;
    fi
    if [ -z "$SESSIONTIMEOUT" ]; then
      echo 'TTL 300' >> $CONFIG_FILE;
    elif [ ! -z "$SESSIONTIMEOUT" ]; then
      echo "TTL $SESSIONTIMEOUT" >> $CONFIG_FILE;
    fi
    echo 'End' >> $CONFIG_FILE;
  fi
  echo 'End' >> $CONFIG_FILE
fi

exec $POUND_BIN $PARAMS
