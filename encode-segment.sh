#!/bin/sh

IN=$1
OUT=$(basename $1 .ts).webm

echo "$IN pass 1"
ffmpeg \
	-y -v warning -nostdin \
	-threads 4 \
	-analyzeduration 40000000 -probesize 100000000 \
	-i $IN \
	\
	-map 0:0 \
	-c:v:0 libvpx -g:0 120 -b:v 1200k -threads 8 -qmin:0 11 -qmax:0 51 -minrate:0 100k -maxrate:0 5000k \
	-pass 1 -passlogfile $OUT-1pass \
	\
	-map 0:1 -c:a:0 libvorbis -b:a:0 96k \
	\
	-aspect 16:9 \
	-f webm \
	$OUT

echo "$IN pass 2"
ffmpeg \
	-y -v warning -nostdin \
	-threads 8 \
	-analyzeduration 40000000 -probesize 100000000 \
	-i $IN \
	\
	-map 0:0 \
	-c:v:0 libvpx \
	-pass 2 -passlogfile $OUT-1pass \
	-g:0 120 -b:v 1200k -qmin:0 11 -qmax:0 51 -minrate:0 100k -maxrate:0 5000k \
	\
	-map 0:1 -c:a:0 libvorbis -b:a:0 96k \
	\
	-aspect 16:9 \
	-f webm \
	$OUT

echo "$IN done"
