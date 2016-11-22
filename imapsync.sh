#!/bin/bash

DOMAIN="example.com"

if [ -z "$1" ]
then
        echo "Syncs IMAP accounts from local to Google domain."
        echo "Usage: ./imapsync.sh <userid> <logdir>"
        echo ""
        exit;
else
        USER=$1
fi

if [ -z "$2" ]
then
        # make LOGDIR a fairly large, permanent directory on your system
        LOGDIR=/var/imapsync/logs
else
        LOGDIR=$2
fi


/usr/bin/imapsync \
        # authentication settions for local server
        --host1 ms0 \
        --user1 "$1" \
        # admin user on a Sun Java Messaging Server
        --authuser1 admin \
        --proxyauth1 \
        # passfile1 contains plaintext password for admin account, set perms carefully
        --passfile1 passfile1.txt \
        --timeout1 0 \
        # Google has deprecated XOAUTH1
        --authmech2 XOAUTH2 \
        --host2 imap.gmail.com \
        --ssl2 \
        --user2 "$1@$DOMAIN" \
        # don't sync this yet until this has been sanitized
        --password2 '<id>;<pcks12 cert file>' \
        --maxsize 25000000 \
        --exitwhenover 500000000 \
        --delete2 \
        --delete2folders \
        --timeout2 0 \
        --regextrans2 's/Sent/[Gmail]\/Sent\ Mail/' \
        --regextrans2 's/Drafts/[Gmail]\/Drafts/' \
        --exclude 'Trash' \
        --exclude "\[Gmail\]$" \
        --regextrans2 "s,(/|^) +,\$1,g" --regextrans2 "s, +(/|$),\$1,g" \
        --regextrans2 "s/[\^]/_/g" \
        --usecache \
        --useuid \
        --logdir "$LOGDIR" \
        --tmpdir /imapsync \
        --nofoldersizes \
        --addheader
