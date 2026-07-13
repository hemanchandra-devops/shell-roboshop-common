#!/bin/bash

source ./common.sh
app_name=catalogue

checkroot
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "setup MongoDB repo service"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATE $? "install mongodb-client"

DB_EXISTS=$(mongosh "$MONGODB_HOST" --quiet --eval "db.getMongo().getDBNames().includes('catalogue')")

if [ "$DB_EXISTS" = "false" ]; then
    mongosh --host "$MONGODB_HOST" </app/db/master-data.js &>>"$LOGS_FILE"
    VALIDATE $? "Load Master Data of the List of products"
else
    echo -e "$Y Already Loaded Master Data of the List of products ...$N Skipping" | tee -a "$LOGS_FILE"
fi

restart