#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
	COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
	COMPOSE_CMD=(docker-compose)
else
	echo "Errore: Docker Compose non trovato. Installa Docker Desktop oppure docker-compose."
	exit 1
fi

if [[ ! -f ".env" ]]; then
	cat > .env <<'EOF'
POSTGRES_DB=imdb
POSTGRES_USER=imdb_user
POSTGRES_PASSWORD=imdb_password
POSTGRES_PORT=5432
EOF
	echo "Creato file .env con valori di default."
fi

usage() {
	cat <<'EOF'
Uso: ./start.sh [comando]

Comandi:
	up      Avvia il DB (inizializza da imdb_small.sql al primo avvio)
	down    Ferma il DB mantenendo i dati
	status  Mostra lo stato dei container
	logs    Mostra i log del DB
	reset   Elimina container e volume dati (bootstrap pulito al prossimo up)

Se non specifichi alcun comando, viene eseguito "up".
EOF
}

command="${1:-up}"

case "$command" in
	up)
		"${COMPOSE_CMD[@]}" up -d
		echo "PostgreSQL in avvio."
		;;
	down)
		"${COMPOSE_CMD[@]}" down
		;;
	status)
		"${COMPOSE_CMD[@]}" ps
		;;
	logs)
		"${COMPOSE_CMD[@]}" logs -f postgres
		;;
	reset)
		"${COMPOSE_CMD[@]}" down -v
		echo "Reset completato: al prossimo ./start.sh up verrà rifatto il bootstrap iniziale."
		;;
	help|-h|--help)
		usage
		;;
	*)
		echo "Comando non riconosciuto: $command"
		usage
		exit 1
		;;
esac
