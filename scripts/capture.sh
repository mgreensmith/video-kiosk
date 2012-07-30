#!/bin/bash

VIDEO_WIDTH=960
VIDEO_HEIGHT=720
FRAMERATE=30

date=/bin/date
capture=/usr/local/bin/capture
gstlaunch=/usr/bin/gst-launch
v4l2ctl=/usr/bin/v4l2-ctl

WORK_DIR=/home/matt/capture-vid
FIFO=$WORK_DIR/cap
PIDFILE=$WORK_DIR/capture.pid

CAPTURE_OPTS="-c 500000 -o"
GST_OPTS="-e"
now=`${date} +%Y%m%d_%H.%M.%S`
OUTFILE=${WORK_DIR}/${now}.mp4

GST_PIPELINE="filesrc location=$FIFO ! h264parse ! queue ! video/x-h264,width=$VIDEO_WIDTH,height=$VIDEO_HEIGHT,framerate=$FRAMERATE/1 ! queue !  mux. pulsesrc device=alsa_input.usb-046d_HD_Pro_Webcam_C920_DDAE38EF-02-C920.analog-stereo latency-time=2000 ! audioconvert ! audiodelay drywet=0 feedback=0 ! lamemp3enc target=1 bitrate=320 cbr=true  ! queue ! mux. mp4mux  name=mux ! filesink location=$OUTFILE"


recording() {
	if [ -s $PIDFILE ] ; then
		kill -0 `cat $PIDFILE` 2>/dev/null
		retval=$?
		[ $retval -eq 0 ] && return 0 || return 1
	fi
	return 1
}

begin_recording() {
	if [[ ! -p $FIFO ]]; then
		mkfifo $FIFO
	fi

	# prep the webcam
	${v4l2ctl} --set-fmt-video=width=$VIDEO_WIDTH,height=$VIDEO_HEIGHT,pixelformat=1
	${v4l2ctl} --set-parm=$FRAMERATE

	${capture} $CAPTURE_OPTS > $FIFO  &
	${gstlaunch} $GST_OPTS $GST_PIPELINE  &
	echo $!>$PIDFILE
}

if ( ! getopts "be" opt); then
	echo "Usage: `basename $0` options -b (begin) -e (end)";
	exit 1;
fi

while getopts ":be" opt; do
	case $opt in
		b)
			# start recording
			recording
			[ $? -ne 0 ] && begin_recording || exit 1
			exit 0
			;;
		e)
			# stop recording
			recording
			[ $? -eq 0 ] && kill -INT `cat $PIDFILE` && rm -f $PIDFILE || exit 1
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			;;
	esac
done
