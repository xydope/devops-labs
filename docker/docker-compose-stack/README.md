# Docker Compose Stack

Small multi-container application demonstrating Docker Compose, Nginx reverse proxying, a Python backend, PostgreSQL, service discovery, health checks, and persistent storage.

## Architecture

```text
Browser
   |
   v
Nginx :8080
   |
   v
Backend :3000
   |
   v
PostgreSQL :5432
   |
   v
Docker volume
```

Only Nginx is exposed to the host. Services communicate through the internal Docker Compose network using service names: `backend` and `db`.

## Services

- **nginx** — serves the static page and forwards `/api/` requests to `backend:3000`.
- **backend** — Flask application with `/health` and `/info` endpoints.
- **db** — PostgreSQL database with a named volume for persistent data.

## Project Structure

```text
docker-compose-stack/
├── compose.yaml
├── .env.example
├── .gitignore
├── README.md
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       └── app.py
└── nginx/
    ├── Dockerfile
    ├── default.conf
    └── index.html
```

## Configuration

Create a local `.env` file from `.env.example` and set the database password.

```bash
Copy-Item .env.example .env
```

`DB_HOST=db` is the Compose service name. It is not `localhost`, because `localhost` inside the backend container refers to the backend container itself.

Do not commit `.env` with real credentials.

## Run

```bash
docker compose up -d --build
docker compose ps
```

Open the frontend at:

```text
http://localhost:8080
```

Stop the stack without removing database data:

```bash
docker compose down
```

## Test

Check the backend through Nginx:

```text
http://localhost:8080/api/health
http://localhost:8080/api/info
```

`/api/info` returns `"database": "connected"` after the backend successfully runs `SELECT 1` against PostgreSQL.

To check volume persistence, run `docker compose down`, start the stack again with `docker compose up -d`, and verify that PostgreSQL starts with the same `postgres_data` volume.

## Useful Commands

```bash
docker compose ps
docker compose logs
docker compose logs backend
docker compose logs db
docker compose exec backend sh
docker compose exec db psql -U app -d app
docker compose config
docker network ls
docker volume ls
```

## Troubleshooting

- If `/api/...` returns an error, check `docker compose logs nginx` and `docker compose logs backend`.
- If the backend cannot connect to PostgreSQL, verify `DB_HOST=db` and inspect `docker compose logs db`.
- If port `8080` does not open, check the Nginx mapping in `compose.yaml` and run `docker compose ps`.
- If a database password was changed after the first start, remember that `POSTGRES_PASSWORD` only initializes an empty PostgreSQL volume. Either restore the original password or recreate the volume when its data is not needed.

## What I Learned

- Building custom Docker images for Nginx and Python.
- Managing multiple services with Docker Compose.
- Using service names for container networking and service discovery.
- Passing configuration through environment variables.
- Persisting PostgreSQL data with a named volume.
- Using health checks and service dependencies.
