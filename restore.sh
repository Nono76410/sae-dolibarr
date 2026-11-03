#!/usr/bin/env bash
# Objectif : restaurer une sauvegarde créée par backup.sh.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

BACKUP_FILE="${1:-}"
[ -f "$BACKUP_FILE" ] || {
    echo "Usage : $0 <sauvegarde.tar.gz>" >&2
    exit 1
}

command -v docker >/dev/null 2>&1 || {
    echo "Docker est requis pour restaurer Dolibarr." >&2
    exit 1
}

if docker compose version >/dev/null 2>&1; then
    COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
else
    echo "Docker Compose est requis pour restaurer Dolibarr." >&2
    exit 1
fi

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
tar -xzf "$BACKUP_FILE" -C "$WORK_DIR"
[ -s "$WORK_DIR/database.sql" ] && [ -f "$WORK_DIR/manifest" ] || {
    echo "Archive invalide : database.sql ou manifest manquant." >&2
    exit 1
}
grep -q '^format=sae-dolibarr-backup-v1$' "$WORK_DIR/manifest" || {
    echo "Format de sauvegarde non supporté." >&2
    exit 1
}

"${COMPOSE[@]}" stop web >/dev/null 2>&1 || true
"${COMPOSE[@]}" up -d db >/dev/null

echo "Attente du démarrage de MariaDB..."
for attempt in $(seq 1 60); do
    if "${COMPOSE[@]}" exec -T db mariadb-admin ping --silent >/dev/null 2>&1; then
        break
    fi
    if [ "$attempt" -eq 60 ]; then
        echo "MariaDB n'est pas disponible après 120 secondes." >&2
        exit 1
    fi
    sleep 2
done

"${COMPOSE[@]}" exec -T db sh -c \
    'mariadb -u root -p"$DOLI_DB_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS \`$DOLI_DB_NAME\`; CREATE DATABASE \`$DOLI_DB_NAME\`;"'
"${COMPOSE[@]}" exec -T db sh -c \
    'mariadb -u "$DOLI_DB_USER" -p"$DOLI_DB_PASSWORD" "$DOLI_DB_NAME"' \
    < "$WORK_DIR/database.sql"

"${COMPOSE[@]}" up -d web >/dev/null
"${COMPOSE[@]}" cp "$WORK_DIR/documents/." web:/var/www/documents/
"${COMPOSE[@]}" cp "$WORK_DIR/conf/." web:/var/www/html/dolibarr/htdocs/conf/

echo "Restauration terminée depuis : $BACKUP_FILE"
