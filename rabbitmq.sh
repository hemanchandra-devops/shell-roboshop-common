#!/bin/bash

source ./common.sh

checkroot

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOGS_FILE
VALIDATE $? "Setup the Rabbitmq repo file"

dnf install rabbitmq-server -y &>>$LOGS_FILE
VALIDATE $? "Install RabbitMQ"

systemctl enable rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Enable RabbitMQ Service"

systemctl start rabbitmq-server &>>$LOGS_FILE
VALIDATE $? "Start RabbitMQ Service"

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