#!/bin/bash

sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" << 'END_SQL'
CREATE TABLE IF NOT EXISTS voegel (
  id TEXT PRIMARY KEY,
  name TEXT,
  anzahl_beobachtungen INTEGER,
  letzte_beobachtung INTEGER
);
END_SQL

while [ true ];do
	if [ -z "$(ls $TSCHILP_ANALYSEVERZEICHNIS)" ]; then
		sleep 60
		continue
	fi
	for datei in "$TSCHILP_ANALYSEVERZEICHNIS/*.txt"; do
		while IFS=$'\t' read -r selection view channel begin_file bgin_time end_time low_freq high_freq species_code common_name confidence rank; do
			timestamp=`basename -s .mp3  $begin_file`
			anzahl=`sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" "SELECT anzahl_beobachtungen FROM voegel WHERE id='$species_code';"`
			if [ -z "$anzahl" ]; then
				echo "Neuer Vogel: $common_name"
				sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" "INSERT INTO voegel VALUES ('$species_code','$common_name',1,'$timestamp')"
				mail -s "Neuer Vogel: $common_name" $TSCHILP_EMAIL_EMPFAENGER -aFrom:Tschilp\<$TSCHILP_EMAIL_ABSENDER\> << 'END_MAIL'
Ein neuer Vogel kam vorbei!
END_MAIL
			else
				echo "Alter Vogel: $common_name ($anzahl)"
				sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" "UPDATE voegel SET anzahl_beobachtungen = anzahl_beobachtungen + 1, letzte_beobachtung = '$timestamp' WHERE id='$species_code';"
			fi
		done < <(tail -n +2 $datei)
		mv $datei $TSCHILP_ANALYSEARCHIV/
	done
	sleep 60
done