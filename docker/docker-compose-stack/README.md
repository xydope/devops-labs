# Docker Compose Stack

Small multi-container application demonstrating Docker Compose, networking, service discovery, PostgreSQL, Nginx, and persistent storage.

## Architecture

```text
Browser
   │
   ▼
Nginx :8080
   │
   ▼
Backend :3000
   │
   ▼
PostgreSQL :5432
   │
   ▼
Docker Volume
```

Only Nginx is exposed to the host.

## Services

* **Nginx** — reverse proxy and static frontend
* **Backend** — Python application
* **PostgreSQL** — application database

Containers communicate through the internal Docker Compose network using service names.

## Project Structure

```text
docker-compose-stack/
├── compose.yaml
├── .env.example
├── .gitignore
├── backend/
│   ├── Dockerfile
│   ├── app.py
│   └── requirements.txt
├── nginx/
│   ├── Dockerfile
│   └── nginx.conf
└── frontend/
    └── index.html
```

## Configuration

Create `.env` from `.env.example` and set the required environment variables.

`.env` is not committed to Git.

## Run

```bash
docker compose up -d --build
```

Open:

```text
http://localhost:8080
```

Check the stack:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs
```

Stop the stack:

```bash
docker compose down
```

## Test

Check the backend through Nginx:

```text
http://localhost:8080/api/info
http://localhost:8080/api/health
```

Verify volumes:

```bash
docker volume ls
```

## Useful Commands

```bash
docker compose ps
docker compose logs -f
docker compose exec backend sh
docker compose exec db psql ...
docker compose config
docker network ls
docker volume ls
```

## What I Learned

* Docker Compose service management
* Container networking and service discovery
* Nginx reverse proxy configuration
* Environment variables
* PostgreSQL containers
* Persistent Docker volumes
* Health checks and service dependencies
* Basic Docker Compose troubleshooting
