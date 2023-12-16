#!/bin/bash
set -e

# Installs whatever certificates have been manually placed in /root.

echo "Adding additional root certificates manually..."
cd /root
cp -v *.crt /usr/local/share/ca-certificates
update-ca-certificates
