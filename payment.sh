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

dnf install python3.11 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing Python and gcc packages"

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

curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment.zip application"

cd /app 
VALIDATE $? "Go to '/app' directory" &>> $LOGFILE

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping payment.zip"

cd /app &>> $LOGFILE
VALIDATE $? "Go to '/app' directory"

pip3.11 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOGFILE
VALIDATE $? "Copying payment.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling Payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting Payment"



