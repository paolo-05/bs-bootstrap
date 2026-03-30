#!/usr/bin/env bash

set -euo pipefail

SQL_FILE="/docker-bootstrap/imdb.sql"

if [[ ! -s "$SQL_FILE" ]]; then
	echo "Errore: dump SQL non trovato o vuoto: $SQL_FILE"
	exit 1
fi

echo "Import bootstrap SQL atomico da $SQL_FILE"

# --single-transaction evita stati parziali: o importa tutto o rollback completo.
psql \
	-v ON_ERROR_STOP=1 \
	--single-transaction \
	--username "$POSTGRES_USER" \
	--dbname "$POSTGRES_DB" \
	-f "$SQL_FILE"

echo "Import bootstrap completato con successo"
