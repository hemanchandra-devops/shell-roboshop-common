#!/bin/bash

source ./common.sh

checkroot

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATE $? "Setup the MongoDB repo file"

dnf install mongodb-org -y &>>$LOGS_FILE
VALIDATE $? "Install MongoDB"

systemctl enable mongod &>>$LOGS_FILE
VALIDATE $? "Enable MongoDB"

systemctl start mongod &>>$LOGS_FILE
VALIDATE $? "Start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGS_FILE
VALIDATE $? "Update listen address"

systemctl restart mongod &>>$LOGS_FILE
VALIDATE $? "Restart the mongod service"