#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%H-%S)
LOGFILE=/tmp/$@-$TIMESTAMP.log

echo -e "$Y Script started executing at $TIMESTAMP $N."

VALIDATE() {
    if  [ $1 -ne 0 ]
    then 
        echo -e "$2...$R FAILED $N."
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e " $R ERROR $N You are not a root user"
    exit 1
fi

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:20 -y &>> $LOGFILE
VALIDATE $? "Enabling NodeJS:20"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS:20"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then 
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Creating 'roboshop' user"
else
    echo -e "roboshop user already exists...$Y SKIPPING $N."
fi

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating '/app' directory"

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading cart.zip application"

cd /app 
VALIDATE $? "Go to '/app' directory" &>> $LOGFILE

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cart.zip"

cd /app &>> $LOGFILE
VALIDATE $? "Go to '/app' directory"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependecies"

cp /home/ec2-user/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying cart.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling Cart"

systemctl start cart &>> $LOGFILE
VALIDATE $? "Starting Cart"
