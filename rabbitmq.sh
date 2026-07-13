#!/bin/bash

source ./common.sh

checkroot

if ! rabbitmqctl list_users | grep -q roboshop; then
    rabbitmqctl add_user roboshop roboshop123 &>>"$LOGS_FILE"
    VALIDATE $? "create one user for the application"

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>"$LOGS_FILE"
    VALIDATE $? "Set permissions for user"
else
    echo -e "$Y Already Roboshop RabbitMQ user exists ...$N Skipping" | tee -a "$LOGS_FILE"
fi


systemctl restart rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Restart the RabbitMQ service"