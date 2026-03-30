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

set_env_var() {
	local key="$1"
	local value="$2"

	if grep -q "^${key}=" .env; then
		awk -v key="$key" -v value="$value" 'BEGIN { FS=OFS="=" } $1 == key { $2=value; found=1 } { print } END { if (!found) print key "=" value }' .env > .env.tmp
		mv .env.tmp .env
	else
		echo "${key}=${value}" >> .env
	fi
}

get_env_var() {
	local key="$1"
	awk -F '=' -v key="$key" '$1 == key { value=substr($0, index($0, "=") + 1) } END { print value }' .env
}

prompt_bootstrap_sql() {
	echo "Scegli il dataset iniziale da importare nel DB:" >&2
	echo "  1) Parziale (imdb_small.sql)" >&2
	echo "  2) Completo (imdb.sql)" >&2

	while true; do
		read -r -p "Selezione [1/2]: " selection
		case "$selection" in
			1)
				echo "imdb_small.sql"
				return
				;;
			2)
				echo "imdb.sql"
				return
				;;
			*)
				echo "Scelta non valida. Inserisci 1 oppure 2." >&2
				;;
		esac
	done
}

choose_bootstrap_sql() {
	local selected_sql

	if [[ -t 0 ]]; then
		selected_sql="$(prompt_bootstrap_sql)"
	else
		selected_sql="imdb_small.sql"
		echo "Terminale non interattivo: uso default ${selected_sql}."
	fi

	set_env_var "BOOTSTRAP_SQL" "$selected_sql"
	echo "Bootstrap configurato su ${selected_sql}."
}

ensure_bootstrap_sql() {
	local selected_sql
	selected_sql="$(get_env_var "BOOTSTRAP_SQL")"

	if [[ "$selected_sql" != "imdb_small.sql" && "$selected_sql" != "imdb.sql" ]]; then
		choose_bootstrap_sql
		selected_sql="$(get_env_var "BOOTSTRAP_SQL")"
	fi

	if [[ ! -f "$selected_sql" ]]; then
		echo "Errore: file SQL '${selected_sql}' non trovato."
		echo "Valori supportati per BOOTSTRAP_SQL: imdb_small.sql, imdb.sql"
		exit 1
	fi
}

usage() {
	cat <<'EOF'
Uso: ./start.sh [comando]

Comandi:
	up      Avvia il DB (chiede il dataset al primo setup)
	down    Ferma il DB mantenendo i dati
	status  Mostra lo stato dei container
	logs    Mostra i log del DB
	dataset Imposta/cambia dataset bootstrap (small/full)
	reset   Elimina container e volume dati (bootstrap pulito al prossimo up)

Se non specifichi alcun comando, viene eseguito "up".
EOF
}

command="${1:-up}"

case "$command" in
	up)
		ensure_bootstrap_sql
		"${COMPOSE_CMD[@]}" up -d
		echo "PostgreSQL in avvio con bootstrap: $(get_env_var "BOOTSTRAP_SQL")"
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
	dataset)
		choose_bootstrap_sql
		echo "Per applicare la nuova scelta su un bootstrap pulito: ./start.sh reset && ./start.sh up"
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
