#!/bin/bash
set -e

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql
	root_mariadb_command="mariadb -u root"
else
	root_mariadb_command="mariadb -u root -p${DOLI_DB_ROOT_PASSWORD}"
fi

mysqld_safe --datadir=/var/lib/mysql --bind-address=0.0.0.0 &

until mariadb-admin ping --silent; do
	sleep 1
done

eval "$root_mariadb_command" <<-SQL
	CREATE DATABASE IF NOT EXISTS \`${DOLI_DB_NAME}\`;
	CREATE USER IF NOT EXISTS '${DOLI_DB_USER}'@'localhost' IDENTIFIED BY '${DOLI_DB_PASSWORD}';
	ALTER USER '${DOLI_DB_USER}'@'localhost' IDENTIFIED BY '${DOLI_DB_PASSWORD}';
	CREATE USER IF NOT EXISTS '${DOLI_DB_USER}'@'%' IDENTIFIED BY '${DOLI_DB_PASSWORD}';
	ALTER USER '${DOLI_DB_USER}'@'%' IDENTIFIED BY '${DOLI_DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON \`${DOLI_DB_NAME}\`.* TO '${DOLI_DB_USER}'@'%';
	GRANT ALL PRIVILEGES ON \`${DOLI_DB_NAME}\`.* TO '${DOLI_DB_USER}'@'localhost';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DOLI_DB_ROOT_PASSWORD}';
	FLUSH PRIVILEGES;
SQL

wait