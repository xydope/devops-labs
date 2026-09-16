# Docker Nginx

A hands-on project for running and configuring Nginx inside Docker.

## What it covers

* Dockerfile and custom image
* Nginx configuration
* Port mapping
* Static HTML
* Docker networking
* Nginx reverse proxy
* Container logs and troubleshooting

## Architecture

```text
Client
  ↓
Nginx :8080
  ↓
Backend container :3000
```

## Project Structure

```text
.
├── Dockerfile
├── html/
│   └── index.html
├── nginx/
│   └── nginx.conf
└── README.md
```

## Run

Build the image:

```bash
docker build -t docker-nginx .
```

Run the container:

```bash
docker run -d \
  --name nginx \
  -p 8080:80 \
  docker-nginx
```

Open:

```text
http://localhost:8080
```

## Useful Commands

```bash
docker ps
docker logs nginx
docker inspect nginx
docker exec -it nginx /bin/sh
docker exec nginx nginx -t
```

## Troubleshooting

The project includes basic troubleshooting of:

* Port mapping
* Nginx configuration
* Container connectivity
* Docker network issues
* Reverse proxy errors
* Container logs

## Goal

Practice Docker and Nginx fundamentals through a small working infrastructure project.
