#!/bin/bash

# Den Ton mit dem angeschlossenen Mikrofon kontinuierlich aufnehmen und in Dateien von 10 Sekunden Länge speichern.

beendet=false

trap beenden SIGINT SIGTERM

function beenden(){
	beendet=true
	echo "Stoppe Aufnahme ..."
}

while [ "$beendet" = false ]; do
	date=$(date +%s)
	arecord -D hw:1 -d 10 -f cd -r 48000 -c 1 "$TSCHILP_AUDIOVERZEICHNIS/$date.tmp"
	mv "$TSCHILP_AUDIOVERZEICHNIS/$date.tmp" "$TSCHILP_AUDIOVERZEICHNIS/$date.wav"
done
