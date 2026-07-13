#!/bin/bash

source ./common.sh

checkroot

dnf module disable redis -y &>>$LOGS_FILE
VALIDATE $? "Diable default redis"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATE $? "enable redis 7 version "

dnf install redis -y  &>>$LOGS_FILE
VALIDATE $? "Install Redis"

systemctl enable redis &>>$LOGS_FILE
VALIDATE $? "Enable redis"

systemctl start redis &>>$LOGS_FILE
VALIDATE $? "Start redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/c protected-mode no' /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATE $? "Update listen address"

systemctl restart redis &>>$LOGS_FILE
VALIDATE $? "Restart the redis service"