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

dnf install redis -y &>> $LOGFILE
VALIDATE $? "Installing Redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOGFILE
VALIDATE $? "Allowing Remote Connection"

systemctl enable redis &>> $LOGFILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>> $LOGFILE
VALIDATE $? "Starting Redis"

