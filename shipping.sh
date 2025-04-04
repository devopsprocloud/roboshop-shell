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

dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing Maven"

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

curl -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping.zip application"

cd /app 
VALIDATE $? "Go to '/app' directory" &>> $LOGFILE

unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Unzipping shipping.zip"

cd /app &>> $LOGFILE
VALIDATE $? "Go to '/app' directory"

mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "renaming shipping-1.0.jar file"

cp /home/ec2-user/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying shipping.service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Reloading Daemon"

systemctl enable shipping &>> $LOGFILE
VALIDATE $? "Enabling Shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting Shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MySQL client"

mysql -h mysql.devopsprocloud.in -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGFILE
VALIDATE $? "Inserting shema.sql into MySQL"

mysql -h mysql.devopsprocloud.in -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGFILE
VALIDATE $? "Inserting app-user.sql into MySQL"

mysql -h mysql.devopsprocloud.in -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGFILE
VALIDATE $? "Inserting master-data.sql into MySQL"

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarting Shipping"
