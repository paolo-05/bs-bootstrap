# PostgreSQL con Docker — Quick Start

Setup rapido di un database PostgreSQL con bootstrap automatico da `imdb_small.sql`.

## Prerequisiti

- Docker Desktop (oppure Docker Engine + Docker Compose)
- Shell bash/zsh

## Avvio rapido

Dalla cartella del progetto:

```bash
./start.sh
```

Se è il primo avvio:

- viene creato il container PostgreSQL
- viene creato il volume persistente
- viene importato `imdb_small.sql` automaticamente

Nei lanci successivi, i dati restano nel volume e **il bootstrap non viene rieseguito**.

## Configurazione

Le variabili sono in `.env.example`:

```env
POSTGRES_DB=imdb
POSTGRES_USER=imdb_user
POSTGRES_PASSWORD=imdb_password
POSTGRES_PORT=5432
```

Puoi modificarle prima dell'avvio.

## Comandi disponibili

```bash
./start.sh up      # avvio DB (default)
./start.sh down    # stop mantenendo i dati
./start.sh status  # stato container
./start.sh logs    # log live di PostgreSQL
./start.sh reset   # cancella anche il volume dati (ripartenza pulita)
./start.sh --help  # help
```

## Connessione al DB

- Host: `localhost`
- Porta: valore di `POSTGRES_PORT` (default `5432`)
- Database: `POSTGRES_DB`
- User: `POSTGRES_USER`
- Password: `POSTGRES_PASSWORD`

Esempio con `psql` locale:

```bash
psql -h localhost -p 5432 -U imdb_user -d imdb
```

## Note utili

- Il file `imdb_small.sql` viene eseguito solo quando il data volume è vuoto.
- Per rifare l'import da zero usa `./start.sh reset` e poi `./start.sh up`.
