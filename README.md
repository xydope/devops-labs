# docker-nginx

Hands-on project: run Nginx in Docker, put it on a custom network, and use it as a reverse proxy to a simple backend container.

## What it does

- Serves a custom static HTML page from an Nginx container
- Uses a custom Nginx config (server block, logs, locations)
- Connects Nginx and a backend over a Docker bridge network
- Proxies `/api/` from Nginx to the backend (`backend:3000`)
- Publishes only Nginx on the host (`8080 → 80`); backend stays internal

## Architecture

```text
Browser
   │
   │ HTTP :8080  (published port on the Docker host)
   ↓
Nginx container (:80 internal)
   │
   ├─ /          → static HTML
   └─ /api/      → reverse proxy
                    │
                    │ Docker network: docker-nginx-net
                    ↓
               Backend container (:3000 internal, not published)
```

Key ideas:

- **Published port ≠ internal port** — host `8080` maps to container `80`
- **`localhost` inside a container is that container**, not the Docker host
- Containers reach each other by **service/container DNS name** on the Docker network (`backend`), not via host `localhost`

## Technologies

- Docker / Docker Compose
- Nginx
- Python (minimal HTTP backend)
- HTTP reverse proxy
- Docker bridge networking

## Requirements

- Docker Engine
- Docker Compose v2 (`docker compose`)

## Project structure

```text
docker-nginx/
├── Dockerfile                 # Nginx image
├── docker-compose.yml         # nginx + backend + network
├── nginx/
│   └── nginx.conf             # server block + reverse proxy
├── html/
│   └── index.html             # static page
├── backend/
│   ├── Dockerfile
│   └── server.py              # tiny JSON HTTP server on :3000
├── .dockerignore
├── .gitignore
└── README.md
```

## Build

Build both images:

```bash
docker compose build
```

Or build only Nginx:

```bash
docker build -t docker-nginx .
```

## Run

Recommended (network + reverse proxy):

```bash
docker compose up -d
```

Open:

- Static page: http://localhost:8080
- Proxied API: http://localhost:8080/api/

Stop:

```bash
docker compose down
```

### Milestone-style: Nginx only (no backend)

```bash
docker build -t docker-nginx .
docker run -d --name nginx -p 8080:80 docker-nginx
```

### Image copy vs bind mount

**Baked into the image** (default): `COPY` in the Dockerfile. Rebuild to change HTML/config.

**Bind mount** (optional, good for learning live edits): uncomment the `volumes` block under `nginx` in `docker-compose.yml`, then:

```bash
docker compose up -d
# edit ./html or ./nginx/nginx.conf on the host
docker exec docker-nginx nginx -s reload
```

## Configuration

Nginx config lives at `nginx/nginx.conf` and is installed in the container as:

```text
/etc/nginx/conf.d/default.conf
```

Document root inside the container:

```text
/usr/share/nginx/html
```

Reverse proxy snippet:

```nginx
location /api/ {
    proxy_pass http://backend:3000/;
}
```

`backend` is the Compose service name; Docker DNS resolves it on `docker-nginx-net`.

## Testing

```bash
# stack up
docker compose up -d

# containers and network
docker compose ps
docker network inspect docker-nginx-net

# static HTML
curl -i http://localhost:8080/

# reverse proxy → backend JSON
curl -i http://localhost:8080/api/

# Nginx config test inside the container
docker exec docker-nginx nginx -t

# logs
docker logs docker-nginx
docker logs docker-nginx-backend
```

Expect:

- `/` → HTML (`Docker Nginx` / `Running successfully`)
- `/api/` → JSON from the backend (`"service": "backend"`)

## Troubleshooting

Use the loop: **symptom → hypothesis → command → evidence → fix**.

### 1. Nothing on http://localhost:8080

| Step | Example |
|------|---------|
| Symptom | `curl` fails / connection refused |
| Hypothesis | Container not running or wrong port mapping |
| Command | `docker compose ps`, `docker port docker-nginx` |
| Evidence | No container, or mapping is not `8080→80` |
| Fix | `docker compose up -d`, check `ports: "8080:80"` |

### 2. Nginx config broken

| Step | Example |
|------|---------|
| Symptom | Container restarts / 502 / empty response |
| Hypothesis | Invalid `nginx.conf` |
| Command | `docker exec docker-nginx nginx -t`, `docker logs docker-nginx` |
| Evidence | `nginx: [emerg] ...` in logs or test output |
| Fix | Correct syntax; rebuild or remount config; `nginx -s reload` |

### 3. `/api/` returns 502 Bad Gateway

| Step | Example |
|------|---------|
| Symptom | Static page OK, `/api/` is 502 |
| Hypothesis | Backend down or wrong upstream name/port |
| Command | `docker compose ps`, `docker logs docker-nginx-backend`, `docker exec docker-nginx wget -qO- http://backend:3000/` |
| Evidence | Backend exited, or connection refused to `backend:3000` |
| Fix | Start backend; fix `proxy_pass http://backend:3000/`; ensure both services share `appnet` |

### 4. Wrong backend hostname in `proxy_pass`

| Step | Example |
|------|---------|
| Symptom | 502; Nginx error log mentions host not found |
| Hypothesis | Used `localhost` or a wrong name instead of the service name |
| Command | `docker logs docker-nginx`, `docker network inspect docker-nginx-net` |
| Evidence | `localhost` inside Nginx is Nginx itself; no listener on 3000 there |
| Fix | Use `http://backend:3000/` (Compose service name on the shared network) |

### 5. Trying to reach backend via host localhost:3000

| Step | Example |
|------|---------|
| Symptom | `curl localhost:3000` fails from the host |
| Hypothesis | Backend port is not published (by design) |
| Command | `docker compose ps`, inspect `ports` in compose |
| Evidence | Only `8080:80` is published |
| Fix | Use `http://localhost:8080/api/` or temporarily publish `3000:3000` for debugging |

### Useful commands

```bash
docker ps
docker logs docker-nginx
docker logs docker-nginx-backend
docker inspect docker-nginx
docker exec -it docker-nginx /bin/sh
docker exec docker-nginx nginx -t
docker network ls
docker network inspect docker-nginx-net
```

## What I Learned

- How to build a custom Nginx image and map host ports to container ports
- Difference between baking files into an image (`COPY`) and bind-mounting from the host
- Where Nginx config and document root live inside the container
- How a Docker bridge network + DNS names connect containers
- Why `localhost` in a container is not the Docker host
- How Nginx reverse proxy (`proxy_pass`) forwards to an internal backend
- How to diagnose common failures with `ps`, `logs`, `exec`, `inspect`, and `curl`
