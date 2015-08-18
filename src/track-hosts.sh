#!/bin/bash

while inotifywait -e close_write /etc/hosts 1>/dev/null 2>/dev/null; do
    python /configure.py | j2 --format=json /etc/pound/backends.j2 > /etc/pound/backends.cfg
    reload
done
