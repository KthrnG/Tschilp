#!/bin/bash

# Wertet das Ergebnis der Analyse aus und versendet eine E-Mail bei neu beobachteten Vögeln.

trap beenden SIGINT SIGTERM

function beenden() {
  echo "Stoppe Analyse ..."
  exit
}

sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" <<'END_SQL'
CREATE TABLE IF NOT EXISTS voegel (
  id TEXT PRIMARY KEY,
  name TEXT,
  anzahl_beobachtungen INTEGER,
  letzte_beobachtung INTEGER,
  confidence FLOAT
);
END_SQL

while [ true ]; do
  if [ -z "$(ls $TSCHILP_ANALYSEVERZEICHNIS)" ]; then
    sleep 60 &
    wait $!
    continue
  fi
  for datei in $TSCHILP_ANALYSEVERZEICHNIS/*.csv; do
    while IFS=$';' read -r start end scientific_name common_name confidence; do
      timestamp=$(basename -s .csv $datei)
      anzahl=$(sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" "SELECT anzahl_beobachtungen FROM voegel WHERE id='$scientific_name';")
      if [ -z "$anzahl" ]; then
        echo "Neuer Vogel: $common_name"
        sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" "INSERT INTO voegel VALUES ('$scientific_name','$common_name',1,'$timestamp','$confidence')"
        mail -s "Neuer Vogel: $common_name" $TSCHILP_EMAIL_EMPFAENGER -aFrom:Tschilp\<$TSCHILP_EMAIL_ABSENDER\> -A $TSCHILP_AUDIOARCHIV/$timestamp.wav <<'END_MAIL'
Ein neuer Vogel kam vorbei! https://de.wikipedia.org/wiki/$scientific_name
END_MAIL
      else
        echo "Alter Vogel: $common_name ($anzahl)"
        sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/beobachtungen.sqlite" "UPDATE voegel SET anzahl_beobachtungen = anzahl_beobachtungen + 1, letzte_beobachtung = '$timestamp', confidence = '$confidence' WHERE id='$scientific_name';"
      fi
    done < <(tail -n +2 $datei)
    mv $datei $TSCHILP_ANALYSEARCHIV/
  done
  sleep 60 &
  wait $!
done
