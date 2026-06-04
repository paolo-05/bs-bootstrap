#!/usr/bin/env bash

set -euo pipefail

JSON_FILE="/docker-bootstrap/movie.json"

if [[ ! -s "$JSON_FILE" ]]; then
	echo "Errore: dataset JSON non trovato o vuoto: $JSON_FILE"
	exit 1
fi

if [[ -z "${MONGO_INITDB_ROOT_USERNAME:-}" || -z "${MONGO_INITDB_ROOT_PASSWORD:-}" || -z "${MONGO_INITDB_DATABASE:-}" ]]; then
	echo "Errore: variabili MONGO_INITDB_* non impostate."
	exit 1
fi

echo "Import bootstrap MongoDB da $JSON_FILE"

mongoimport \
	--username "$MONGO_INITDB_ROOT_USERNAME" \
	--password "$MONGO_INITDB_ROOT_PASSWORD" \
	--authenticationDatabase admin \
	--db "$MONGO_INITDB_DATABASE" \
	--collection movies \
	--file "$JSON_FILE"

echo "Import MongoDB completato con successo"
