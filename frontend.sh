#!/bin/bash

source ./common.sh

checkroot

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATE $? "Disable default Nginx"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATE $? "Enable Nginx 1.24 version"

dnf install nginx -y &>>$LOGS_FILE
VALIDATE $? "Install Nginx"

systemctl enable nginx &>>$LOGS_FILE
VALIDATE $? "Enable Nginx" 

systemctl start nginx &>>$LOGS_FILE
VALIDATE $? "Start Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGS_FILE
VALIDATE $? "Remove default html code"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGS_FILE
VALIDATE $? "Download frontend code"

cd /usr/share/nginx/html &>>$LOGS_FILE
VALIDATE $? "Move to the nginx htlm dir"

unzip /tmp/frontend.zip &>>$LOGS_FILE
VALIDATE $? "Unzip the frontend code"

cp $SCRIPT_DIR/nginx.conf  /etc/nginx/nginx.conf &>>$LOGS_FILE
VALIDATE $? "Create Nginx Reverse Proxy Configuration"

systemctl restart nginx &>>$LOGS_FILE
VALIDATE $? "Restart nginx"