#!/bin/bash

# Aufgenommene Audiodateien mit BIRD.net analysieren.

trap beenden SIGINT SIGTERM

function beenden() {
  echo "Stoppe Analyse ..."
  exit
}

function analysieren() {
  for datei in $TSCHILP_AUDIOVERZEICHNIS/*.wav; do
    timestamp=$(basename -s .wav $datei)
    week=$(date +%V)
    python3 analyze.py --i "$datei" --o $TSCHILP_ANALYSEVERZEICHNIS/$timestamp.csv --min_conf 0.6 --week $week --lat 53.073 --lon 8.806
    mv $datei $TSCHILP_AUDIOARCHIV/
  done
}

cd $TSCHILP_BIRDNETVERZEICHNIS || exit

while true; do
  if [ -n "$(ls $TSCHILP_AUDIOVERZEICHNIS)" ]; then
    analysieren
  fi
  sleep 3 &
  wait $!
done
