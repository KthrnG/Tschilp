#!/bin/bash

arecord -D hw:1 -d 10 -f S16_LE -r 48000 test.wav
