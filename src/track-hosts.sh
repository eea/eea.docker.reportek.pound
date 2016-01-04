#!/bin/bash
PIDFILE=/opt/pound/var/track_hosts.pid

(echo "$BASHPID" > $PIDFILE; exec inotifywait -e modify -m -q /etc/hosts) | \
while IFS= read file event; do
    python /opt/configure.py | j2 --format=json /opt/pound/etc/backends.j2 > /opt/pound/etc/backends.cfg
    /opt/reload.sh
done
