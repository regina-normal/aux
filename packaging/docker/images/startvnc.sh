#!/bin/bash
set -e

if [ -e /usr/bin/vncserver ]; then
  cmd=/usr/bin/vncserver
elif [ -e /usr/bin/X11/vncserver ]; then
  cmd=/usr/bin/X11/vncserver
else
  echo 'ERROR: Cannot locate vncserver executable'
  exit 1
fi

"$cmd" :1 -geometry 1280x960 -rfbport 5901
sleep infinity
