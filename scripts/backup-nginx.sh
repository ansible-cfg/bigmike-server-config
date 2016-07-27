#!/bin/bash

TIMESTAMP=$(date +"%F")
BACKUP="/var/backups/nginx"
BACKUPDIR="$BACKUP/$TIMESTAMP"
AGE=7

mkdir -p "$BACKUPDIR"

if [ ! -d $BACKUPDIR ]; then
	echo "Backup destination folder: $BACKUPDIR does not exist."; echo
	exit 1
fi

for dir in /var/www/accounts/*
do
  base=$(basename "$dir")
  tar -zcf "$BACKUPDIR/$base.tar.gz" -C /var/www/accounts "${base}"
done

tar -zcf $BACKUPDIR.tar.gz -C $BACKUP $TIMESTAMP

if test $? -eq 0
then
	rm -rf $BACKUPDIR
else
	echo "Backup file not created." >&2
	exit 1
fi

# echo "Cleaning up old backups (older than $AGE days) and temporary files"
find $BACKUP -mindepth 1 -maxdepth 1 -ctime +$AGE -exec echo "removing: "{} \; -exec rm -rf {} \;

ncftpput -V -u "backup" -p "backup123" home.codeone.pl /BigMike/nginx $BACKUP/$TIMESTAMP.tar.gz

exit 0