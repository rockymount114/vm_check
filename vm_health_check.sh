#!/bin/bash

echo "==============================="
echo "   VM HEALTH CHECK & FIX TOOL"
echo "==============================="
echo

###########################################
# 1. MEMORY CHECK
###########################################

echo "[1] MEMORY USAGE:"
free -h
echo

###########################################
# 2. DISK CHECK
###########################################

echo "[2] DISK USAGE:"
df -h /
df -h /var
echo

###########################################
# 3. CHECK DOCKER DIRECTORY SIZE
###########################################

echo "[3] DOCKER STORAGE USAGE:"
if [ -d "/var/lib/docker" ]; then
    sudo du -sh /var/lib/docker
else
    echo "Docker not installed or /var/lib/docker missing."
fi
echo

###########################################
# 4. FIND LARGE DOCKER LOG FILES
###########################################

echo "[4] SCANNING FOR LARGE DOCKER LOG FILES (>200MB)..."
LOGS=$(sudo find /var/lib/docker/containers -type f -name "*-json.log" -size +200M 2>/dev/null)

if [ -z "$LOGS" ]; then
    echo "No large Docker logs found."
else
    echo "Large log files found:"
    echo "$LOGS"
    echo
    echo "Truncating logs..."
    while IFS= read -r file; do
        sudo truncate -s 0 "$file"
        echo "Cleared: $file"
    done <<< "$LOGS"
    echo
    echo "Log cleanup complete."
fi
echo

###########################################
# 5. DOCKER SYSTEM REPORT
###########################################

echo "[5] DOCKER SYSTEM DF:"
if command -v docker &> /dev/null; then
    docker system df
else
    echo "Docker not installed."
fi
echo

###########################################
# 6. CHECKING DOCKER LOG ROTATION
###########################################

echo "[6] CHECKING DOCKER LOG ROTATION..."
if [ -f /etc/docker/daemon.json ]; then
    echo "Docker daemon.json exists. Contents:"
    cat /etc/docker/daemon.json
else
    echo "WARNING: Docker log rotation not configured."
    echo "Recommended daemon.json configuration:"
    echo '{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}'
fi

echo
echo "==============================="
echo "        CHECK COMPLETE"
echo "==============================="