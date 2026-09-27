# Containerized Python App

A minimal Flask web application containerized with **Docker and Docker Compose**.

The project demonstrates basic containerization concepts: Dockerfiles, images, containers, port mapping, environment variables, health checks, non-root users, and Compose.

## Endpoints

| Endpoint  | Description                        |
| --------- | ---------------------------------- |
| `/`       | Application status                 |
| `/health` | Health check                       |
| `/info`   | Container hostname and environment |

## Project Structure

```text
containerized-python-app/
├── app/
│   └── app.py
├── requirements.txt
├── Dockerfile
├── compose.yaml
├── .env.example
├── .dockerignore
├── .gitignore
└── README.md
```

## Run with Docker Compose

Create environment configuration:

```bash
cp .env.example .env
```

Start the application:

```bash
docker compose up -d
```

Check status:

```bash
docker compose ps
```

Test the API:

```bash
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/info
```

Stop:

```bash
docker compose down
```

## Configuration

`.env.example`:

```text
APP_ENV=development
APP_PORT=3000
HOST_PORT=3000
```

Compose uses these values for runtime configuration:

```yaml
ports:
  - "${HOST_PORT}:${APP_PORT}"

environment:
  APP_ENV: ${APP_ENV}
  APP_PORT: ${APP_PORT}
```

`HOST_PORT` is the host port. `APP_PORT` is the port used by the application inside the container.

## Docker

The Dockerfile:

* uses a Python slim image;
* installs dependencies from `requirements.txt`;
* copies the application;
* creates a non-root user;
* runs the application as that user.

The application listens on:

```text
0.0.0.0:3000
```

Docker publishes the port:

```text
localhost:3000 → container:3000
```

`EXPOSE` documents the container port; it does not publish it.

## Health Check

Compose checks:

```text
/health
```

Container states:

```text
Up       → process is running
healthy  → health check passes
unhealthy → health check fails
```

The restart policy is configured separately with:

```yaml
restart: unless-stopped
```

## Troubleshooting

Useful commands:

```bash
docker compose ps
docker compose logs
docker compose config
docker ps
docker logs containerized-python-app
docker exec -it containerized-python-app sh
docker inspect containerized-python-app
```

Common issues include incorrect port mapping, wrong environment variables, failed health checks, and binding the application to `127.0.0.1` instead of `0.0.0.0`.

## What I Learned

* Dockerfile build process
* Images vs containers
* Docker layers and build cache
* Port publishing
* Environment variables
* Health checks
* Non-root containers
* Docker Compose
* `.env` configuration
* Basic container troubleshooting
