#!/bin/bash

set -e

R="\e[31m"
G="\e[32m"
Y="\e[33m" 
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
mkdir -p $LOGS_FOLDER
SCRIPIT_NAME=$(echo $0 | cut -d "." -f1)
LOGS_FILE="$LOGS_FOLDER/$SCRIPIT_NAME.log"
MONGODB_HOST=mongodb.heman.icu
MYSQL_HOST=mysql.heman.icu
SCRIPT_DIR=$PWD

echo "Script started executed at : $(date)" | tee -a $LOGS_FILE


VALIDATE(){
    if [ $1 -ne 0 ];then
        echo -e "$R $2 ... $N Failure" | tee -a $LOGS_FILE
        exit 1
    else 
        echo -e "$G $2 ... $N Success" | tee -a $LOGS_FILE
    fi
}


checkroot(){
    USERID=$(id -u)

    if [ $USERID -ne 0 ];then
        echo -e "$R Please run this script with Root Access! $N" | tee -a $LOGS_FILE
        exit 1
    fi
}


app_setup(){
    if ! id roboshop &>>"$LOGS_FILE"; then
        useradd --system --home /app --shell /sbin/nologin \
            --comment "roboshop system user" roboshop &>>"$LOGS_FILE"
        VALIDATE $? "Add application User"
    else
        echo -e "$Y Already Roboshop user exists ...$N Skipping" | tee -a "$LOGS_FILE"
    fi

    mkdir -p /app &>>$LOGS_FILE
    VALIDATE $? "setup an app directory"

    curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOGS_FILE
    VALIDATE $? "Download the application code"

    cd /app 
    VALIDATE $? "Move to app directory"

    rm -rf /app/*
    VALIDATE $? "Application files may already exist"

    unzip /tmp/catalogue.zip &>>$LOGS_FILE
    VALIDATE $? "Unzip the catalogue code" 
}

nodejs_setup(){
    dnf module disable nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Disable current module"

    dnf module enable nodejs:20 -y &>>$LOGS_FILE
    VALIDATE $? "Enable required module"

    dnf install nodejs -y &>>$LOGS_FILE
    VALIDATE $? "Install NodeJS"

    npm install &>>$LOGS_FILE
    VALIDATE $? "Download the dependencies" 
}

maven_setup(){
    dnf install maven -y &>>$LOGS_FILE
    VALIDATE $? "Install Maven"

    mvn clean package &>>$LOGS_FILE
    VALIDATE $? "download the dependencies" 

    mv target/shipping-1.0.jar shipping.jar &>>$LOGS_FILE
    VALIDATE $? "Moveing shipping jar to current dir" 
}

python_setup(){
    dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
    VALIDATE $? "Install Python 3"

    pip3 install -r requirements.txt &>>$LOGS_FILE
    VALIDATE $? "Download the dependencies" 
}

systemd_setup(){
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service &>>$LOGS_FILE
    VALIDATE $? "Setup SystemD Catalogue Service"

    systemctl daemon-reload &>>$LOGS_FILE
    VALIDATE $? "Load the $app_name service"

    systemctl enable $app_name &>>$LOGS_FILE
    VALIDATE $? "enable the $app_name service"

    systemctl start $app_name &>>$LOGS_FILE
    VALIDATE $? "Start the $app_name service"
}

restart(){
    systemctl restart $app_name &>>$LOGS_FILE
    VALIDATE $? "Restart the $app_name service"
}