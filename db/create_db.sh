#!/bin/bash

function datenbank_anlegen() {
  sqlite3 voegel.sqlite "CREATE TABLE IF NOT EXISTS voegel(scientific_name TEXT PRIMARY KEY, name_en TEXT, name_de TEXT, avibase_url TEXT, wikipedia_url TEXT,img TEXT);"
}

function datenbank_fuellen() {
  IFS=$'\n'
  for vogel in $(jq -c .[] ../voegel.json); do
    scientific_name=$(echo $vogel | jq '.scientific_name')
    name_en=$(echo $vogel | jq '.name_en')
    name_de=$(echo $vogel | jq '.name_de')
    avibase_url=$(echo $vogel | jq '.avibase_url')
    wikipedia_url=$(echo $vogel | jq '.wikipedia_url')
    img=$(echo $vogel | jq '.img')
    sqlite3 voegel.sqlite "INSERT INTO voegel VALUES($scientific_name,$name_en,$name_de,$avibase_url,$wikipedia_url,$img);"
  done
}

datenbank_anlegen
datenbank_fuellen
