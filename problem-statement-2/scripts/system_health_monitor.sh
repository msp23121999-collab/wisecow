#!/bin/bash
#############################################
# System Health Monitoring Script
# Checks CPU, Memory, Disk usage, and process count.
# Logs an alert if any metric exceeds its threshold.
#############################################

CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=80

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/system_health.log"

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

log_info()  { echo "[$(timestamp)] INFO: $1" >> "$LOG_FILE"; }
log_alert() { echo "[$(timestamp)] ALERT: $1" | tee -a "$LOG_FILE"; }

check_cpu() {
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk -F',' '{print $4}' | awk '{print $1}')
    cpu_usage=$(echo "100 - $cpu_idle" | bc)
    cpu_usage_int=${cpu_usage%.*}
    log_info "CPU usage: ${cpu_usage_int}%"
    if [ "$cpu_usage_int" -ge "$CPU_THRESHOLD" ]; then
        log_alert "CPU usage is high: ${cpu_usage_int}% (threshold: ${CPU_THRESHOLD}%)"
    fi
}

check_memory() {
    mem_total=$(free -m | awk '/Mem:/ {print $2}')
    mem_used=$(free -m | awk '/Mem:/ {print $3}')
    mem_usage=$(( 100 * mem_used / mem_total ))
    log_info "Memory usage: ${mem_usage}% (${mem_used}MB / ${mem_total}MB)"
    if [ "$mem_usage" -ge "$MEM_THRESHOLD" ]; then
        log_alert "Memory usage is high: ${mem_usage}% (threshold: ${MEM_THRESHOLD}%)"
    fi
}

check_disk() {
    disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    log_info "Disk usage (/): ${disk_usage}%"
    if [ "$disk_usage" -ge "$DISK_THRESHOLD" ]; then
        log_alert "Disk usage is high: ${disk_usage}% (threshold: ${DISK_THRESHOLD}%)"
    fi
}

check_processes() {
    process_count=$(ps aux --no-headers | wc -l)
    log_info "Running processes: ${process_count}"
}

main() {
    echo "----- System Health Check: $(timestamp) -----" >> "$LOG_FILE"
    check_cpu
    check_memory
    check_disk
    check_processes
}

main
