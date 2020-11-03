#!/bin/bash

while [ true ]; do
  DATE=`date`
  arecord -D hw:1 -d 10 -f S16_LE -r 48000 "$DATE.wav"
done