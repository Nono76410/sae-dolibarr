#!/bin/bash

sudo apt install apt-transport-https lsb-release ca-certificates wget -y
sudo wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt update

sudo apt install apache2 php8.2 php8.2-cli php8.2-common php8.2-mysql php8.2-gd php8.2-curl php8.2-intl php8.2-mbstring php8.2-xml php8.2-zip php8.2-imap libapache2-mod-php8.2 -y

cd /tmp
wget https://github.com/Dolibarr/dolibarr/archive/refs/tags/20.0.0.tar.gz
tar -zxvf 20.0.0.tar.gz
sudo rm -rf /var/www/html/dolibarr
sudo mv dolibarr-20.0.0 /var/www/html/dolibarr

sudo chown -R www-data:www-data /var/www/html/dolibarr
sudo chmod -R 755 /var/www/html/dolibarr

sudo bash -c 'cat > /etc/apache2/sites-available/dolibarr.conf <<EOF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/html/dolibarr/htdocs

    <Directory "/var/www/html/dolibarr/htdocs">
        Options +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/dolibarr_error.log
    CustomLog \${APACHE_LOG_DIR}/dolibarr_access.log combined
</VirtualHost>
EOF'

sudo a2dissite 000-default.conf
sudo a2ensite dolibarr.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

echo "=== Dolibarr est installé ! ==="