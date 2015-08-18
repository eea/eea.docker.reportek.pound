#!/bin/bash
set -x

CONFIG_FILE='/etc/pound/config.cfg'
POUND_BIN='/usr/local/sbin/pound'
PARAMS="-f $CONFIG_FILE"

python /configure.py | j2 --format=json /etc/pound/backends.j2 > /etc/pound/backends.cfg

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
  else
    echo 'Include "/etc/pound/backends.cfg"' >> $CONFIG_FILE
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
track_hosts &

exec $POUND_BIN $PARAMS
