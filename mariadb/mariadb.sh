#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install mariadb-server mariadb-client -y

sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql -e "CREATE DATABASE IF NOT EXISTS dolibarr;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'dolibarr'@'localhost' IDENTIFIED BY 'azerty1234';"
sudo mysql -e "GRANT ALL PRIVILEGES ON dolibarr.* TO 'dolibarr'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "MariaDB est installé et la base 'dolibarr' est prête !"