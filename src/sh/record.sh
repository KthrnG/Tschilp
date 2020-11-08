#!/bin/bash

beendet=false

trap beenden SIGINT
trap beenden SIGTERM

function beenden(){
	beendet=true
	echo "Stoppe Aufnahme..."
}

while [ "$beendet" = false ]; do
	date=$(date +%s)
	arecord -D hw:1 -d 10 -f cd -r 48000 -c 1 | lame -v - "$TSCHILP_AUDIOVERZEICHNIS/$date.tmp"
	mv "$TSCHILP_AUDIOVERZEICHNIS/$date.tmp" "$TSCHILP_AUDIOVERZEICHNIS/$date.mp3"
done
