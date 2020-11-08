#!/bin/bash

while [ true ]; do
	if [ -n "$(ls $TSCHILP_AUDIOVERZEICHNIS)" ]; then
		docker run -v $TSCHILP_AUDIOVERZEICHNIS:/audio -v $TSCHILP_ANALYSEVERZEICHNIS:/analyse birdnet --i /audio --o /analyse --filetype mp3 --min_conf 0.95 --week `date +%V`
	    	mv $TSCHILP_AUDIOVERZEICHNIS/*.mp3 $TSCHILP_AUDIOARCHIV
      	fi
	sleep 60
done
