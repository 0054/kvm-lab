#!/bin/bash
PATH=/etc:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

PASSW_FILE='/home/nifi/rsyncd.secrets'
USER='test'
RSYNC_SERVER='10.10.1.20'
SOURCE='data'
DEST='/home/nifi/data/'

rsync -au --password-file=$PASSW_FILE $USER@$RSYNC_SERVER::$SOURCE $DEST

