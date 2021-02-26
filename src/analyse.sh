#!/bin/bash

# Aufgenommene Audiodateien mit BIRD.net analysieren.

beendet=false

trap beenden SIGINT SIGTERM

function beenden(){
	echo "Stoppe Analyse ..."
}

cd $TSCHILP_BIRDNETVERZEICHNIS

while [ true ]; do
	if [ -z "$(ls $TSCHILP_AUDIOVERZEICHNIS)" ]; then
		sleep 60 & wait $!
		continue
	fi
	for datei in $TSCHILP_AUDIOVERZEICHNIS/*.wav; do
		timestamp=`basename -s .wav $datei`
		python3 analyze.py --i "$datei" --o "$TSCHILP_ANALYSEVERZEICHNIS/$timestamp.csv" --min_conf 0.5 --week `date +%V` --lat 53.073 --lon 8.806
	       	mv $datei $TSCHILP_AUDIOARCHIV/
	done
	sleep 60 & wait $!
done
