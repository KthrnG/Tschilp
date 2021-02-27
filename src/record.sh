#!/bin/bash

# Den Ton mit dem angeschlossenen Mikrofon kontinuierlich aufnehmen und in Dateien von 10 Sekunden Länge speichern.

trap beenden SIGINT SIGTERM

function beenden() {
  echo "Stoppe Aufnahme ..."
  exit
}

function aufnehmen() {
  date=$(date +%s)
  arecord -D hw:1 -d 3 -f cd -r 48000 -c 1 "$TSCHILP_AUDIOVERZEICHNIS/$date.tmp"
  mv "$TSCHILP_AUDIOVERZEICHNIS/$date.tmp" "$TSCHILP_AUDIOVERZEICHNIS/$date.wav"
}

while true; do
  aufnehmen
done
