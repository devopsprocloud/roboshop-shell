#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%H-%S)
LOGFILE=/tmp/$0-$TIMESTAMP.log

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

dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing Naginx"

systemctl enable nginx &>> $LOGFILE
VALIDATE $? "Enabling Naginx"

systemctl start nginx &>> $LOGFILE
VALIDATE $? "Starting Naginx"

rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "InstallRemoving the old code"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "Downloading web.zip file"

cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "go to the /html directory"

unzip /tmp/web.zip &>> $LOGFILE
VALIDATE $? "unzipping we.zip file"

cp /home/ec2-user/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "Copying roboshop.conf file"

systemctl restart nginx &>> $LOGFILE
VALIDATE $? "Restarting Naginx"

