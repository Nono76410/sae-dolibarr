#!/usr/bin/env bash
# Objectif : créer une sauvegarde portable de la base et des fichiers Dolibarr.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

command -v docker >/dev/null 2>&1 || {
    echo "Docker est requis pour sauvegarder Dolibarr." >&2
    exit 1
}

if docker compose version >/dev/null 2>&1; then
    COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
else
    echo "Docker Compose est requis pour sauvegarder Dolibarr." >&2
    exit 1
fi

if ! "${COMPOSE[@]}" exec -T db mariadb-admin ping --silent >/dev/null 2>&1; then
    echo "MariaDB doit être démarrée avant la sauvegarde." >&2
    exit 1
fi

BACKUP_DIR="${1:-$PROJECT_DIR/backups}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/dolibarr-$TIMESTAMP.tar.gz"
DATABASE_NAME="${DOLI_DB_NAME:-dolibarr}"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$BACKUP_DIR" "$WORK_DIR/documents" "$WORK_DIR/conf"

"${COMPOSE[@]}" exec -T db sh -c \
    'mariadb-dump --single-transaction --routines --events --triggers "$DOLI_DB_NAME"' \
    > "$WORK_DIR/database.sql"
"${COMPOSE[@]}" cp web:/var/www/documents/. "$WORK_DIR/documents/"
"${COMPOSE[@]}" cp web:/var/www/html/dolibarr/htdocs/conf/. "$WORK_DIR/conf/"

cat > "$WORK_DIR/manifest" <<EOF
format=sae-dolibarr-backup-v1
created_at=$TIMESTAMP
database=$DATABASE_NAME
EOF

tar -C "$WORK_DIR" -czf "$BACKUP_FILE" database.sql documents conf manifest
echo "Sauvegarde créée : $BACKUP_FILE"
