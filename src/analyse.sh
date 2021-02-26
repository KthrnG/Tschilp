#!/bin/bash

# Aufgenommene Audiodateien mit BIRD.net analysieren.

beendet=false

trap beenden SIGINT SIGTERM

function beenden(){
	beendet=true
	echo "Stoppe Analyse ..."
}

while [ "$beendet" = false ]; do
	if [ -n "$(ls $TSCHILP_AUDIOVERZEICHNIS)" ]; then
        # docker run -v $TSCHILP_AUDIOVERZEICHNIS:/audio -v $TSCHILP_ANALYSEVERZEICHNIS:/analyse birdnet --i /audio --o /analyse --filetype mp3 --min_conf 0.95 --week `date +%V`--lat 53.073 --lon 8.806
		docker run -v $TSCHILP_AUDIOVERZEICHNIS:/audio -v $TSCHILP_ANALYSEVERZEICHNIS:/analyse birdnet --i /audio --o /analyse --filetype wav --min_conf 0.95 --week `date +%V`
        mv $TSCHILP_AUDIOVERZEICHNIS/*.wav $TSCHILP_AUDIOARCHIV
    fi
	sleep 60
done
