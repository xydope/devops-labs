#!/usr/bin/env bash

hostname_value=$(hostname)
uptime_line=$(uptime)

uptime_value=$(printf '%s\n' "$uptime_line" | sed 's/.* up \([^,]*\).*/\1/')
load_value=${uptime_line##*load average: }
cpu_value=$(top -bn1 | awk '/^%Cpu/ {print int($2 + $4)}')
memory_value=$(free | awk '
    /^Mem:/ {
        total = $2
        used = $3 + $5 + $6
        print int((used * 100) / total)
    }
')
disk_value=$(df / | awk 'NR==2 { print $5 }' | tr -d '%')
services=("ssh" "nginx" "docker")

printf '=== SYSTEM STATUS ===\n\n'
printf 'Hostname: %s\n' "$hostname_value"
printf 'Uptime: %s\n' "$uptime_value"
printf 'Load: %s\n' "$load_value"
printf 'CPU: %s%%\n' "$cpu_value"
printf 'Memory: %s%%\n' "$memory_value"
printf 'Disk /: %s%%\n' "$disk_value"
printf '\nServices:\n'

for service in "${services[@]}"; do
  service_status=$(systemctl is-active "$service" 2> /dev/null)

  if [ "$service_status" = "active" ]; then
    status_text="OK"
  elif systemctl cat "$service" &> /dev/null; then
    status_text="DOWN"
  else
    status_text="NOT FOUND"
  fi

  service_name=${service^^}
  printf '%s: %s\n' "$service_name" "$status_text"
done
