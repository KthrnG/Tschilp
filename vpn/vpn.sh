#!/bin/bash

VPNC=/usr/sbin/vpnc

while true; do
  if nc -w2 -z $TSCHILP_SERVER; then
    exit
  fi
  if nc -w3 -z $TSCHILP_SERVER; then
    exit
  fi
  if nc -w4 -z $TSCHILP_SERVER; then
    exit
  fi
  echo "$(date): unable to connect to target, restarting VPN..."
  $VPNC $TSCHILP_VPN_CONFIG
  sleep 60 &
  wait $!
done
