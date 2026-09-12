# linux-monitor

A simple Bash-based Linux system monitor that prints basic host status information and health checks.

## What it shows

- Hostname
- Uptime
- Load average
- CPU usage
- Memory usage
- Disk usage for /
- Service status for a predefined list of services
- Warnings for high usage / unhealthy services

## Run

```bash
bash linux-monitor.sh
```

## Example output

```text
=== SYSTEM STATUS ===

Hostname: ubuntu-server
Uptime: 2 days, 4 hours
Load: 0.72, 0.65, 0.58
CPU: 23% [OK]
Memory: 58% [OK]
Disk /: 64% [OK]

Services:
SSH: OK
NGINX: CRITICAL
DOCKER: WARNING

Warnings:
- NGINX service is down
- DOCKER service is not installed
```

## Notes

- Written in Bash.
- Uses standard Linux utilities such as `uptime`, `top`, `free`, `df`, and `systemctl`.
- Keeps the script intentionally simple and easy to read for learning and demo purposes.
