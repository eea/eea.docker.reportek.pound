#!/bin/bash
CONFIG_FILE='/opt/pound/etc/config.cfg'
set -x
if [ -z $BACKENDS_PORT ]; then
  export BACKENDS_PORT='8080'
fi

python /opt/configure.py | j2 --format=json /opt/pound/etc/backends.j2 > /opt/pound/etc/backends.cfg

if [ -f "$CONFIG_FILE" ]; then
  echo 'Using mounted config file'
else
  echo 'User "pound"' > $CONFIG_FILE
  echo 'Group "pound"' >> $CONFIG_FILE
  echo 'Daemon 1' >> $CONFIG_FILE
  echo 'LogLevel 3' >> $CONFIG_FILE
  echo 'LogFacility local1' >> $CONFIG_FILE

  if [ ! -z "$ALIVE" ]; then echo "Alive $ALIVE" >> $CONFIG_FILE; fi
  if [ ! -z "$CLIENT" ]; then echo "Client $CLIENT" >> $CONFIG_FILE; fi
  if [ ! -z "$TIMEOUT" ]; then echo "TimeOut $TIMEOUT" >> $CONFIG_FILE; fi
  echo 'ListenHTTP' >> $CONFIG_FILE
  echo 'Address 0.0.0.0' >> $CONFIG_FILE
  echo 'Port 8080' >> $CONFIG_FILE
  echo 'End' >> $CONFIG_FILE
  echo 'Service' >> $CONFIG_FILE

  if [ ! -z "$BACKENDS" ]; then
    for BACKEND in $(echo "$BACKENDS" | tr ' ' '\n'); do
      echo 'Backend' >> $CONFIG_FILE
      IFS=':' read -a address <<< "$BACKEND"
      echo "Address ${address}" >> $CONFIG_FILE
      echo "Port ${BACKENDS_PORT}" >> $CONFIG_FILE
      echo 'End' >> $CONFIG_FILE
    done
  else
    python /opt/configure.py | j2 --format=json /opt/pound/etc/backends.j2 > /opt/pound/etc/backends.cfg
    echo 'Include "/opt/pound/etc/backends.cfg"' >> $CONFIG_FILE
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
