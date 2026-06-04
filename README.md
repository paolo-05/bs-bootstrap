# PostgreSQL + MongoDB con Docker — Quick Start

Setup rapido di PostgreSQL e MongoDB con bootstrap automatico da dataset IMDb (SQL + JSON).

## Prerequisiti

- Docker Desktop (oppure Docker Engine + Docker Compose)
- Shell bash/zsh

## Avvio rapido

Dalla cartella del progetto:

```bash
./start.sh
```

Se è il primo avvio:

- vengono creati i container PostgreSQL e MongoDB
- vengono creati i volumi persistenti
- lo script chiede quale dataset importare in PostgreSQL:
  - parziale: `imdb_small.sql`
  - completo: `imdb.sql`
- MongoDB importa automaticamente `movie.json` nel database configurato

Nei lanci successivi, i dati restano nei volumi e **il bootstrap non viene rieseguito**.

La scelta viene salvata in `.env` nella variabile `BOOTSTRAP_SQL`.

## Configurazione

Le variabili sono in `.env.example`:

```env
POSTGRES_DB=imdb
POSTGRES_USER=imdb_user
POSTGRES_PASSWORD=imdb_password
POSTGRES_PORT=5432
MONGO_DB=imdb
MONGO_ROOT_USER=imdb_root
MONGO_ROOT_PASSWORD=imdb_root_password
MONGO_PORT=27017
```

Puoi modificarle prima dell'avvio.

## Comandi disponibili

```bash
./start.sh up      # avvio DB (default)
./start.sh down    # stop mantenendo i dati
./start.sh status  # stato container
./start.sh logs    # log live di PostgreSQL e MongoDB
./start.sh dataset # imposta/cambia dataset bootstrap (small/full)
./start.sh reset   # cancella anche il volume dati (ripartenza pulita)
./start.sh --help  # help
```

Per applicare un cambio dataset su un bootstrap pulito:

```bash
./start.sh dataset
./start.sh reset
./start.sh up
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

### MongoDB

- Host: `localhost`
- Porta: valore di `MONGO_PORT` (default `27017`)
- Database: `MONGO_DB`
- User: `MONGO_ROOT_USER`
- Password: `MONGO_ROOT_PASSWORD`

Esempio connection string:

```text
mongodb://imdb_root:imdb_root_password@localhost:27017/imdb?authSource=admin
```
```

## Note utili

- Il file impostato in `BOOTSTRAP_SQL` viene eseguito solo quando il volume PostgreSQL è vuoto.
- L'import di `movie.json` in MongoDB avviene solo quando il volume MongoDB è vuoto.
- Per rifare l'import da zero usa `./start.sh reset` e poi `./start.sh up`.
- L'import iniziale viene eseguito in transazione unica: in caso di errore non rimane uno stato parziale.
- Se hai gia' un volume con import incompleto, esegui `./start.sh reset` prima di riavviare `./start.sh up`.
