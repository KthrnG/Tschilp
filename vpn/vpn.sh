#!/bin/bash

trap beenden SIGINT SIGTERM

function beenden() {
  echo "Stoppe VPN ..."
  vpnc-disconnect
  exit
}

while true; do
  ping -c 3 $TSCHILP_SERVER
  if [ $? -eq 0 ]; then
    echo "Connection to $TSCHILP_SERVER successful. Doing nothing."
    sleep 60 &
    wait $!
  else
    echo "Unable to connect to target. Restarting VPN..."
    vpnc $TSCHILP_VPN_CONFIG
  fi
done
