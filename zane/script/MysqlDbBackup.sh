vim /zane/scripts/MysqlDbBackup.sh

#!/bin/bash

MYSQLHOSTNAME="localhost"      
MYSQLUSERNAME="freya"
MYSQLPASSWORD="Lassi@2882"   

DOC="/data/DbBackup"  
          


TIMESTAMP=`date +"%Y%m%d-%H%M"`
 
DATABASES=`mysql -h $MYSQLHOSTNAME -u $MYSQLUSERNAME -p $MYSQLPASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v "(Database|information_schema|mysql|performance_schema)"`

find $DOC/*.sql.gz -mtime +5 -exec rm {} ;
		
for db in $DATABASES; do
	FILENAME="$db-$TIMESTAMP.sql.gz"
	echo -e "e[1;34m$dbe[00m"
	echo -e " creating e[0;35m$FILENAMEe[00m"
    mysqldump --single-transaction -h $MYSQLHOST -u $MYSQLUSER -p $MYSQLPASS --databases "$db" | gzip -c > "$DOC/$FILENAME"
    echo -e " Uploading db dump on S3 bucket"
    s3cmd put $DOC/$FILENAME s3://zane-interview-challenge/freya-mehta/
    if [ $? -ne 0 ]; then
	echo -e "Error in Mysql Dump Live Database" 
	exit 1
	fi
done;
echo -e "Hi Sysadmin,Live Database Backups successfully done"
