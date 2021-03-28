#!/bin/bash

# Wertet das Ergebnis der Analyse aus und versendet eine E-Mail bei neu beobachteten Vögeln.

trap beenden SIGINT SIGTERM

function beenden() {
  echo "Stoppe Benachrichtigung ..."
  exit
}

function datenbank_anlegen() {
  sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/tschilp.sqlite" "CREATE TABLE IF NOT EXISTS beobachtungen (scientific_name TEXT PRIMARY KEY,anzahl_beobachtungen INTEGER,letzte_beobachtung INTEGER,confidence FLOAT);"
}

function neuer_vogel() {
  mkdir -p "$TSCHILP_VERZEICHNIS/tmp"
  echo "Neuer Vogel: $scientific_name"
  sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/tschilp.sqlite" "INSERT INTO beobachtungen VALUES ('$scientific_name',1,'$timestamp','$confidence')"
  scientific_name=$scientific_name \
    name_de=$(sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/tschilp.sqlite" "SELECT name_de FROM voegel WHERE scientific_name='$scientific_name'") \
    wikipedia_url=$(sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/tschilp.sqlite" "SELECT wikipedia_url FROM voegel WHERE scientific_name='$scientific_name'") \
    img=$(sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/tschilp.sqlite" "SELECT img FROM voegel WHERE scientific_name='$scientific_name'") \
    envsubst <"$TSCHILP_VERZEICHNIS/template/email.html" >"$TSCHILP_VERZEICHNIS/tmp/email.html"
  lame $TSCHILP_AUDIOARCHIV/$timestamp.wav "$TSCHILP_VERZEICHNIS/tmp/$timestamp.mp3"
  sendemail \
    -S "$(which sendmail)" \
    -u "Tschilp!" \
    -f "Tschilp <fabian.grote@posteo.de>" \
    -t "$TSCHILP_EMAIL_EMPFAENGER" \
    -a "$TSCHILP_VERZEICHNIS/tmp/$timestamp.mp3" \
    -o message-charset=utf-8 \
    <"$TSCHILP_VERZEICHNIS/tmp/email.html"
}

function alter_vogel() {
  echo "Alter Vogel: $scientific_name ($anzahl)"
  sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/tschilp.sqlite" "UPDATE beobachtungen SET anzahl_beobachtungen = anzahl_beobachtungen + 1, letzte_beobachtung = '$timestamp', confidence = '$confidence' WHERE scientific_name='$scientific_name';"
}

function benachrichtigen() {
  for datei in $TSCHILP_ANALYSEVERZEICHNIS/*.csv; do
    while IFS=$';' read -r start end scientific_name common_name confidence; do
      timestamp=$(basename -s .csv $datei)
      anzahl=$(sqlite3 "$TSCHILP_DATENBANKVERZEICHNIS/tschilp.sqlite" "SELECT anzahl_beobachtungen FROM beobachtungen WHERE scientific_name='$scientific_name';")
      if [ -z "$anzahl" ]; then
        neuer_vogel
      else
        alter_vogel
      fi
    done < <(tail -n +2 $datei)
    mv $datei $TSCHILP_ANALYSEARCHIV/
  done
}

datenbank_anlegen

while true; do
  if [ -n "$(ls $TSCHILP_ANALYSEVERZEICHNIS)" ]; then
    benachrichtigen
  fi
  sleep 3 &
  wait $!
done
