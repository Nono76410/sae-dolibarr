#!/bin/bash
set -e

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe --datadir=/var/lib/mysql --bind-address=0.0.0.0 &

until mariadb-admin ping --silent; do
	sleep 1
done

mariadb <<-SQL
	CREATE DATABASE IF NOT EXISTS \`${DB_NAME:-dolibarr}\`;
	CREATE USER IF NOT EXISTS '${DB_USER:-dolibarr}'@'%' IDENTIFIED BY '${DB_PASSWORD:-azerty1234}';
	ALTER USER '${DB_USER:-dolibarr}'@'%' IDENTIFIED BY '${DB_PASSWORD:-azerty1234}';
	GRANT ALL PRIVILEGES ON \`${DB_NAME:-dolibarr}\`.* TO '${DB_USER:-dolibarr}'@'%';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD:-azerty1234}';
	FLUSH PRIVILEGES;
SQL

wait