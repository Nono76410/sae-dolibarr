#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

command -v docker >/dev/null 2>&1 || {
    echo "Docker est requis pour installer Dolibarr." >&2
    exit 1
}

if docker compose version >/dev/null 2>&1; then
    COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
else
    echo "Docker Compose est requis pour installer Dolibarr." >&2
    exit 1
fi

mkdir -p mariadb/data
"${COMPOSE[@]}" up -d --build

echo "Attente du démarrage de MariaDB..."
for attempt in $(seq 1 60); do
    if "${COMPOSE[@]}" exec -T db mariadb-admin ping --silent >/dev/null 2>&1; then
        echo "MariaDB est prête."
        break
    fi
    if [ "$attempt" -eq 60 ]; then
        echo "MariaDB n'est pas disponible après 120 secondes." >&2
        "${COMPOSE[@]}" logs db
        exit 1
    fi
    sleep 2
done

if ! "${COMPOSE[@]}" ps --status running | grep -q 'web'; then
    echo "Le service web n'est pas démarré." >&2
    "${COMPOSE[@]}" logs web
    exit 1
fi

echo "Dolibarr est disponible sur http://localhost:8080"
echo "Import CSV : ./import.sh test.csv"
