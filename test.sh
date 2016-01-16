#!/bin/sh

SEGMENT_SECS=30
PARALLEL_JOBS=5

echo "downloading/checking input file"
wget -nc http://cdn.media.ccc.de/congress/2015/h264-hd/32c3-7551-en-de-Closing_Event_hd.mp4 -O in.mp4

echo "segmenting file"
rm -f segment-*
ffmpeg \
	-y -v warning -nostdin \
	-i in.mp4 \
	-bsf:v h264_mp4toannexb \
	-c:a copy -c:v copy \
	-map 0:v -map 0:a \
	-flags +global_header -flags +ilme+ildct \
	-f segment -segment_time ${SEGMENT_SECS} -segment_format mpegts \
	segment-%05d.ts

echo "parallel encoding segments"
parallel -j $PARALLEL_JOBS sh encode-segment.sh -- segment-*.ts

echo "assembling encoded segments"
rm -f merged.webm
mkvmerge -v --webm -o merged.webm `ls -1 segment-*.webm | tr '\n' ' ' | sed 's/ $//g' | sed 's/ / \+ /g'`

echo "remuxing w/ original audio"
ffmpeg -i merged.webm -i in.mp4 -map 0:v -map 1:a -c:v copy -c:a libvorbis -b:a:0 96k out-with-original-audio.webm

echo "remuxing w/ merged audio"
ffmpeg -i merged.webm -map 0:v -map 0:a -c:v copy -c:a copy out-with-asselbled-audio.webm
