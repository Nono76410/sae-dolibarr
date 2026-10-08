FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY conf.php /opt/dolibarr.conf.php
COPY enable-modules.php /opt/enable-modules.php
COPY seed-demo.php /opt/seed-demo.php

RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2 libapache2-mod-php \
    php php-cli php-common php-mysql php-gd php-curl php-intl \
    php-mbstring php-xml php-zip php-imap \
    wget ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/Dolibarr/dolibarr/archive/refs/tags/20.0.0.tar.gz -O /tmp/doli.tar.gz \
    && tar -xzf /tmp/doli.tar.gz -C /tmp \
    && mv /tmp/dolibarr-20.0.0 /var/www/html/dolibarr \
    && rm /tmp/doli.tar.gz

RUN mkdir -p /var/www/documents \
    && chown -R www-data:www-data /var/www/html/dolibarr /var/www/documents

COPY dolibarr.conf /etc/apache2/sites-available/dolibarr.conf
RUN a2dissite 000-default.conf && a2ensite dolibarr.conf && a2enmod rewrite

EXPOSE 80
CMD ["/entrypoint.sh"]