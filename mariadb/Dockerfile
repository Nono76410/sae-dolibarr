FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Autoriser les connexions depuis les autres conteneurs
# (par défaut MariaDB n'écoute que sur 127.0.0.1)
RUN sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

# Script de démarrage
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3306
ENTRYPOINT ["/entrypoint.sh"]