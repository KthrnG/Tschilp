#!/bin/bash

# Alle MP3 Dateien in dem Tschilp Audioverzeichnis per ssh auf einen Server kopieren und anschließend löschen.

beendet=false

trap beenden SIGINT SIGTERM

function beenden(){
	beendet=true
	echo "Stoppe Transfer ..."
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
