# docker-nginx

Simple Docker setup with Nginx in front of a small Python backend.

## What it does

- Serves a static HTML page on port `8080`
- Proxies `/api/` to the backend service
- Uses Docker networking so containers talk by service name, not `localhost`

## Architecture

```text
Browser → Nginx (container) → backend (container)
          :8080                 :3000
```

## Run

```bash
docker compose up -d
```

Open:

- http://localhost:8080/
- http://localhost:8080/api/

Stop:

```bash
docker compose down
```

## Files

- `nginx/nginx.conf` — Nginx config with reverse proxy
- `html/index.html` — static page
- `backend/server.py` — minimal backend
- `docker-compose.yml` — container setup

## Notes

- Nginx listens on port `80` inside the container and is exposed to the host as `8080:80`.
- The backend is reachable internally as `http://backend:3000`.
- Do not use `localhost` inside Nginx for the upstream; it points to the Nginx container itself.
