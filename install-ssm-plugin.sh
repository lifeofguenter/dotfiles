#!/usr/bin/env bash

set -ex

curl -OLf# "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip"
unzip sessionmanager-bundle.zip
rm -f sessionmanager-bundle.zip
rm -rf /usr/local/sessionmanagerplugin
sudo python3 ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
