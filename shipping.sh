#!/bin/bash

source ./common.sh
app_name=shipping

checkroot
app_setup
maven_setup
systemd_setup
dnf install mysql -y &>>$LOGS_FILE
VALIDATE $? "install mysql client"


mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 -e "USE cities;" &>>"$LOGS_FILE"

if [ $? -ne 0 ]; then
    mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/schema.sql &>>"$LOGS_FILE"
    VALIDATE $? "Load schema to database"

    mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/app-user.sql &>>"$LOGS_FILE"
    VALIDATE $? "Create application user"

    mysql -h "$MYSQL_HOST" -uroot -pRoboShop@1 < /app/db/master-data.sql &>>"$LOGS_FILE"
    VALIDATE $? "Load master data"
else
    echo -e "$Y Already loaded schema to the Database ...$N Skipping" | tee -a "$LOGS_FILE"
fi

restart
