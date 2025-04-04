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

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Downloading user.zip application"

cd /app 
VALIDATE $? "Go to '/app' directory" &>> $LOGFILE

unzip -o /tmp/user.zip &>> $LOGFILE
VALIDATE $? "Unzipping user.zip"

cd /app &>> $LOGFILE
VALIDATE $? "Go to '/app' directory"

npm install &>> $LOGFILE
VALIDATE $? "Installing dependecies"

cp /home/ec2-user/roboshop-shell/user.service /etc/systemd/system/user.service &>> $LOGFILE
VALIDATE $? "Copying user.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable user &>> $LOGFILE
VALIDATE $? "Enabling User"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting User"

cp /home/ec2-user/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copying Mongo Repo"

dnf install -y mongodb-mongosh &>> $LOGFILE
VALIDATE $? "Installing MongoDB Client"

mongosh --host mongodb.devopsprocloud.in </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Inserting user.js into MongpoDB"