#!/bin/sh
set -e

install -o www-data -g www-data -m 0640 \
    /opt/dolibarr.conf.php \
    /var/www/html/dolibarr/htdocs/conf/conf.php

chmod 0440 /var/www/html/dolibarr/htdocs/conf/conf.php

admin_login="${DOLI_ADMIN_LOGIN}"
admin_password="${DOLI_ADMIN_PASSWORD}"

if ! php -r '$db = new mysqli(getenv("DOLI_DB_HOST"), getenv("DOLI_DB_USER"), getenv("DOLI_DB_PASSWORD"), getenv("DOLI_DB_NAME"), (int) getenv("DOLI_DB_PORT")); exit((int) (!$db->query("SHOW TABLES LIKE '\''llx_user'\''")? true : $db->query("SHOW TABLES LIKE '\''llx_user'\''")->num_rows === 0));'; then
    rm -f /var/www/documents/install.lock
    cd /var/www/html/dolibarr/htdocs/install
    php step2.php set fr_FR
    php step5.php "" "" fr_FR set "$admin_login" "$admin_password" "$admin_password" 444
    if ! php -r '$db = new mysqli(getenv("DOLI_DB_HOST"), getenv("DOLI_DB_USER"), getenv("DOLI_DB_PASSWORD"), getenv("DOLI_DB_NAME"), (int) getenv("DOLI_DB_PORT")); exit((int) (!$db->query("SELECT rowid FROM llx_user LIMIT 1") || $db->query("SELECT rowid FROM llx_user LIMIT 1")->num_rows === 0));'; then
        php step5.php "" "" fr_FR set "$admin_login" "$admin_password" "$admin_password" 444
    fi
fi

php /opt/configure-demo.php

touch /var/www/documents/install.lock
chmod 0444 /var/www/documents/install.lock

exec apache2ctl -D FOREGROUND
