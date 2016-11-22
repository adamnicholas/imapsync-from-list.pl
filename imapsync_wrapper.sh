#!/bin/bash

# imapsync_wrapper.sh <userid> <sync directory>

# Wrapper for imapsync.sh that keeps track of failed attempts
# In a sane world, this is being called by one of the google-sync Perl scripts
# that is running multithreaded. Going to have to build something
# into either this script or that one to detect if a failure is due to an
# IMAP disconnect or hitting the 500mb limit with Google

IMAPSYNC="imapsync.sh"

if [ -z "$1" ]
then
        echo "$0 <NetID> <sync directory>"
        exit
fi

if [ -z "$2" ]
then
        ISYNCDIR=$(pwd)
else
        ISYNCDIR="$2"
fi

NETID=$1
TIMESTAMP=$(date +%Y_%m_%d_%H_%M_%S)
LOGDIR="${ISYNCDIR}/logs"

if [ ! -d "$LOGDIR" ]
then
        mkdir "$LOGDIR" 
fi

LOGFILE="${LOGDIR}/${TIMESTAMP}_${NETID}@example.com.txt"

#Run the sync
"$IMAPSYNC" "$NETID" "$LOGDIR" >/dev/null 2>&1

FAILURE=$(egrep -woc "Failure|err" "$LOGFILE" | grep -v "Delete")

if [ $FAILURE -gt 0 ]
then
        echo "$NETID" " " "$TIMESTAMP" >> "$ISYNCDIR"/failed.txt
fi

rm -f "$ISYNCDIR"/temp_"$NETID".txt
