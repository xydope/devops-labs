# Docker Persistence

One Flask container writing the same kind of file to three paths — container filesystem, named volume, and bind mount — to show what survives recreate.

## What this covers

- Container writable layer vs mounts
- Named volumes
- Bind mounts
- `-v` / Compose `volumes`
- Data persistence across stop/start and remove/recreate

## Layout

```text
docker-persistence/
├── app/
│   ├── app.py
│   └── requirements.txt
├── Dockerfile
├── compose.yaml
└── README.md
```

| Path in container   | Mount                         | Survives recreate |
|---------------------|-------------------------------|-------------------|
| `/container/...`    | none (container FS)           | no                |
| `/volume/...`       | named volume `volume`         | yes               |
| `/bind/...`         | bind `./bind`                 | yes               |

## Run

```bash
docker compose up --build
```

Open http://localhost:8080

## Experiment

1. Click **write** on all three rows.
2. `docker compose down` then `docker compose up` (do not use `-v`).
3. Reload the page.

Expected:

- `container` → `(empty)` / lost
- `volume` → message kept
- `bind` → message kept (also visible under `./bind` on the host)

Stop/start alone keeps all three. Only remove/recreate drops container FS data.

```bash
docker compose down
```

Named volume data stays until `docker compose down -v` or `docker volume rm`.
