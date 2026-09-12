#!/usr/bin/env bash

hostname_value=$(hostname)
uptime_line=$(uptime)

uptime_value=$(printf '%s\n' "$uptime_line" | sed 's/.* up \([^,]*\).*/\1/')

load_value=${uptime_line##*load average: }

printf '=== SYSTEM STATUS ===\n\n'
printf 'Hostname: %s\n' "$hostname_value"
printf 'Uptime: %s\n' "$uptime_value"
printf 'Load: %s\n' "$load_value"
