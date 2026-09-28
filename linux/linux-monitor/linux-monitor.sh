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

cpu_warning_threshold=80
memory_warning_threshold=90
disk_warning_threshold=85
warnings_text=""

if [ "$cpu_value" -ge "$cpu_warning_threshold" ]; then
  cpu_status="WARNING"
  warnings_text+="- CPU usage above ${cpu_warning_threshold}%\n"
else
  cpu_status="OK"
fi

if [ "$memory_value" -ge "$memory_warning_threshold" ]; then
  memory_status="WARNING"
  warnings_text+="- Memory usage above ${memory_warning_threshold}%\n"
else
  memory_status="OK"
fi

if [ "$disk_value" -ge "$disk_warning_threshold" ]; then
  disk_status="WARNING"
  warnings_text+="- Disk usage above ${disk_warning_threshold}%\n"
else
  disk_status="OK"
fi

printf '=== SYSTEM STATUS ===\n\n'
printf 'Hostname: %s\n' "$hostname_value"
printf 'Uptime: %s\n' "$uptime_value"
printf 'Load: %s\n' "$load_value"
printf 'CPU: %s%% [%s]\n' "$cpu_value" "$cpu_status"
printf 'Memory: %s%% [%s]\n' "$memory_value" "$memory_status"
printf 'Disk /: %s%% [%s]\n' "$disk_value" "$disk_status"
printf '\nServices:\n'

for service in "${services[@]}"; do
  service_status=$(systemctl is-active "$service" 2> /dev/null)

  if [ "$service_status" = "active" ]; then
    status_text="OK"
  elif systemctl cat "$service" &> /dev/null; then
    status_text="CRITICAL"
    service_name=${service^^}
    warnings_text+="- ${service_name} service is down\n"
  else
    status_text="WARNING"
    service_name=${service^^}
    warnings_text+="- ${service_name} service is not installed\n"
  fi

  printf '%s: %s\n' "${service^^}" "$status_text"
done

printf '\nWarnings:\n'
if [ -n "$warnings_text" ]; then
  printf '%b' "$warnings_text"
else
  printf 'None\n'
fi
