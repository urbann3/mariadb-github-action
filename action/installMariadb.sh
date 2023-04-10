#!/bin/bash

VERSION=""
DB_USER=""
DB_PASS=""
DB_NAME=""

# get parameters
while getopts "v:u:p:n:" opt
do
  case "${opt}" in
    v) VERSION=${OPTARG};;
    u) DB_USER=${OPTARG};;
    p) DB_PASS=${OPTARG};;
    n) DB_NAME=${OPTARG};;
  esac
done

# clear previous data
sudo systemctl stop mysql.service
sudo rm -rf /var/lib/mysql

# install maria db
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
echo "deb https://downloads.mariadb.com/MariaDB/mariadb-${VERSION}/repo/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) main" | sudo tee /etc/apt/sources.list.d/mariadb.list
sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/mariadb.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
sudo apt-get install mariadb-server-${VERSION}

# start maria db
sudo systemctl start mariadb

# set root password
sudo mysqladmin -proot password 'root'

# add user
mysql -u root -proot -e "CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost'"
mysql -u root -proot -e "FLUSH PRIVILEGES"

# add database
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -u root -proot -e "GRANT ALL ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
mysql -u root -proot -e "GRANT ALL ON ${DB_NAME}.* TO 'root'@'localhost' IDENTIFIED BY 'root';"
mysql -u root -proot -e "FLUSH PRIVILEGES;"

# restart service
sudo systemctl restart mariadb
