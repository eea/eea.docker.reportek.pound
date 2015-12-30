#!/bin/bash
set -x
PIDFILE=/var/run/track_hosts.pid

(echo "$BASHPID" > $PIDFILE; exec inotifywait -e close_write /etc/hosts) | \
while IFS= read file event; do
    python /configure.py | j2 --format=json /etc/pound/backends.j2 > /etc/pound/backends.cfg
    reload
done
