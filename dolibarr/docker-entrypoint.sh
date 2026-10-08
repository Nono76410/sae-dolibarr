#!/bin/sh
set -e

install -o www-data -g www-data -m 0640 \
    /opt/dolibarr.conf.php \
    /var/www/html/dolibarr/htdocs/conf/conf.php

admin_login="${DOLI_ADMIN_LOGIN:-dolibarr}"
admin_password="${DOLI_ADMIN_PASSWORD:-azerty1234}"

if ! php -r '$db = new mysqli("db", "dolibarr", "azerty1234", "dolibarr", 3306); exit((int) (!$db->query("SHOW TABLES LIKE '\''llx_user'\''")? true : $db->query("SHOW TABLES LIKE '\''llx_user'\''")->num_rows === 0));'; then
    cd /var/www/html/dolibarr/htdocs/install
    php step2.php set fr_FR
    php step5.php "" "" fr_FR set "$admin_login" "$admin_password" "$admin_password" 444
fi

php /opt/configure-demo.php

exec apache2ctl -D FOREGROUND
