#!/bin/bash
#############################################
# Application Health Checker
# Checks if a given URL is UP or DOWN by HTTP status code.
# Usage: ./app_health_checker.sh [URL]
#############################################

APP_URL="${1:-http://localhost:4499}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/app_health.log"

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$APP_URL")

if [ "$status_code" -ge 200 ] && [ "$status_code" -lt 400 ]; then
    echo "[$(timestamp)] UP - $APP_URL responded with HTTP $status_code" | tee -a "$LOG_FILE"
else
    echo "[$(timestamp)] DOWN - $APP_URL responded with HTTP $status_code" | tee -a "$LOG_FILE"
fi
