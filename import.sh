#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

CSV_FILE="${1:-test.csv}"
[ -f "$CSV_FILE" ] || {
    echo "Fichier CSV introuvable : $CSV_FILE" >&2
    exit 1
}

if docker compose version >/dev/null 2>&1; then
    COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
    COMPOSE=(docker-compose)
else
    echo "Docker Compose est requis pour importer les données." >&2
    exit 1
fi

sql_escape() {
    local value="$1"
    value=${value//\\/\\\\}
    value=${value//\'/\'\'}
    printf "%s" "$value"
}

user_id=$("${COMPOSE[@]}" exec -T db sh -c \
    'mariadb -N -B -u "$DOLI_DB_USER" -p"$DOLI_DB_PASSWORD" "$DOLI_DB_NAME" -e "SELECT rowid FROM llx_user ORDER BY rowid LIMIT 1;"')

[ -n "$user_id" ] || {
    echo "Aucun utilisateur Dolibarr n'est disponible." >&2
    exit 1
}

sql_file=$(mktemp)
trap 'rm -f "$sql_file"' EXIT

printf 'START TRANSACTION;\n' > "$sql_file"

{
    IFS= read -r header || true
    while IFS=';' read -r name client_code customer_code country email phone thirdparty_type || [ -n "$name" ]; do
        name=${name//$'\r'/}
        name=${name#\"}
        name=${name%\"}
        customer_code=${customer_code#\"}
        customer_code=${customer_code%\"}
        email=${email#\"}
        email=${email%\"}
        phone=${phone#\"}
        phone=${phone%\"}
        thirdparty_type=${thirdparty_type//$'\r'/}
        thirdparty_type=${thirdparty_type#\"}
        thirdparty_type=${thirdparty_type%\"}

        [ -n "$name" ] || continue

        escaped_name=$(sql_escape "$name")
        escaped_email=$(sql_escape "$email")
        escaped_phone=$(sql_escape "$phone")

        client_value=0
        supplier_value=0
        client_sql="NULL"
        supplier_sql="NULL"
        if [ "$client_code" = "1" ]; then
            client_value=1
            client_sql="'$(sql_escape "$customer_code")'"
        else
            supplier_value=1
            supplier_sql="'$(sql_escape "$customer_code")'"
        fi

        cat >> "$sql_file" <<SQL
INSERT INTO llx_societe
    (nom, entity, statut, status, code_client, code_fournisseur, fk_pays,
     email, phone, client, fournisseur, tva_assuj, fk_stcomm, datec, fk_user_creat)
SELECT '$escaped_name', 1, 1, 1, $client_sql, $supplier_sql, 1,
       '$escaped_email', '$escaped_phone', $client_value, $supplier_value,
       1, 0, NOW(), $user_id
WHERE NOT EXISTS (
    SELECT 1 FROM llx_societe
    WHERE nom = '$escaped_name'
       OR ('$customer_code' <> '' AND (code_client = '$customer_code' OR code_fournisseur = '$customer_code'))
);
SQL
    done
} < "$CSV_FILE"

printf 'COMMIT;\n' >> "$sql_file"
"${COMPOSE[@]}" exec -T db sh -c \
    'mariadb -u "$DOLI_DB_USER" -p"$DOLI_DB_PASSWORD" "$DOLI_DB_NAME"' < "$sql_file"

echo "Import terminé depuis $CSV_FILE."
