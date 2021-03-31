#!/bin/bash
set -e

# Copyright © 2009 Stefano Zacchiroli <zack@upsilon.cc>
# Modified by Ben Burton to make this specific to signing Regina's
# debian/ubuntu package repository.
#
# Usage: sign-remote.sh [regina|backports]
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

if [ -z "$1" ]; then
  repo=regina
else
  repo="$1"
fi

case "$repo" in
  regina )
    suites="buster bionic focal groovy"
    ;;
  backports )
    suites="buster bionic"
    ;;
  * )
    echo "Usage: $0 [regina|backports]"
    exit 1
    ;;
esac

host=people.debian.org

for suite in $suites; do
  echo "--------------------"
  echo "$repo / $suite"
  echo "--------------------"
  echo "I: preparing to sign $repo for $suite ..."
  path="/home/bab/public_html/$repo/$suite/Release"
  base=$(dirname "$path")

  tmp=`mktemp -t sign`
  sig="$tmp.gpg"
  trap "rm -f $tmp $sig" EXIT

  echo "I: retrieving file to sign from remote host ..."
  scp "$host:$path" $tmp
  echo "I: signing ..."
  gpg --default-key 0x542D38D9 --digest-algo SHA256 --detach-sign -a -o $sig $tmp
  echo "I: sending back signature ..."
  scp $sig "$host":"$path.gpg"
  echo "I: remote signing done."
done
