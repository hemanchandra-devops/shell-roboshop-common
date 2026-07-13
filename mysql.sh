#!/bin/bash

source ./common.sh

checkroot

dnf install mysql-server -y &>>$LOGS_FILE
VALIDATE $? "Install MySQL Server"

systemctl enable mysqld &>>$LOGS_FILE
VALIDATE $? "Start MySQL Service"

systemctl start mysqld &>>$LOGS_FILE
VALIDATE $? "Start MySQL Service"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGS_FILE
VALIDATE $? "Setup Mysql Root Password"

systemctl restart mysqld &>>$LOGS_FILE
VALIDATE $? "Restart the MySQL service"