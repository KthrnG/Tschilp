#!/bin/bash

#WLAN Verbindung berücksichtigen
#Kontinuität

beendet=false

trap beenden SIGINT
trap beenden SIGTERM

function beenden(){
	beendet=true
	echo "Stoppe Transfer..."
}

function kopierenUndLoeschen(){
	for audiodatei in "$TSCHILP_AUDIOVERZEICHNIS/*.mp3" ; do
		scp $audiodatei $TSCHILP_USER@$TSCHILP_SERVER:$TSCHILP_ZIELVERZEICHNIS
		if [ "$?" -eq 0 ]; then
			rm $audiodatei
		fi
	done
}

while [ "$beendet" = false ]; do
	if [ -n "$(ls -A $TSCHILP_AUDIOVERZEICHNIS)" ]; then
		kopierenUndLoeschen
	fi
	sleep 60s
done
