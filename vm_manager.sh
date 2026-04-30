#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

pause() { echo; read -p "Press Enter to continue..."; }


############################################################
# HEALTH CHECKS
############################################################

health_check() {
    echo -e "${CYAN}=== QUICK HEALTH CHECK ===${RESET}"
    echo
    echo "[Memory]"
    free -h
    echo

    echo "[Disk]"
    df -h /
    df -h /var
    echo

    echo "[Docker Storage]"
    if [ -d "/var/lib/docker" ]; then
        du -sh /var/lib/docker
    else
        echo "Docker not installed."
    fi
}

full_diagnostics() {
    echo -e "${CYAN}=== FULL DIAGNOSTICS ===${RESET}"
    echo
    
    echo "[Load Average]"
    uptime
    echo
    
    echo "[Memory]"
    free -h
    echo
    
    echo "[Disk Usage]"
    df -h
    echo
    
    echo "[Top 10 disk-consuming paths]"
    du -xh / | sort -h | tail -n 10
    echo
    
    echo "[Large Docker Logs >200MB]"
    sudo find /var/lib/docker/containers -type f -name "*-json.log" -size +200M 2>/dev/null
}

############################################################
# CLEANUP (Default Yes on Enter)
############################################################

prompt() {
    read -p "$1 (Y/n): " ans
    ans=${ans:-y}
    [[ "${ans,,}" == "y" ]]
}

clean_apt_cache() {
    if prompt "Clean apt cache?"; then
        sudo apt clean
        sudo apt autoclean
        echo -e "${GREEN}✓ Apt cache cleaned${RESET}"
    fi
}

clean_old_kernels() {
    if prompt "Remove old kernels?"; then
        sudo apt autoremove --purge -y
        echo -e "${GREEN}✓ Old kernels removed${RESET}"
    fi
}

clean_journal_logs() {
    if prompt "Vacuum journal logs to 200MB?"; then
        sudo journalctl --vacuum-size=200M
        echo -e "${GREEN}✓ Journal logs cleaned${RESET}"
    fi
}

clean_snap_cache() {
    if command -v snap &> /dev/null; then
        if prompt "Remove old snap versions?"; then
            sudo snap set system refresh.retain=2
            sudo du -sh /var/lib/snapd
            echo -e "${GREEN}✓ Snap cache cleaned${RESET}"
        fi
    else
        echo "Snap not installed."
    fi
}

docker_prune_safe() {
    if prompt "Prune unused Docker images & volumes?"; then
        docker system prune -f
        docker volume prune -f
        echo -e "${GREEN}✓ Docker prune completed${RESET}"
    fi
}

docker_log_cleanup() {
    echo -e "${CYAN}Scanning for large Docker logs...${RESET}"
    LOGS=$(sudo find /var/lib/docker/containers -type f -name "*-json.log" -size +200M 2>/dev/null)

    if [ -z "$LOGS" ]; then
        echo "No large logs found."
        return
    fi

    echo "$LOGS"
    echo
    if prompt "Truncate all large Docker logs?"; then
        while IFS= read -r file; do
            sudo truncate -s 0 "$file"
            echo "Cleared: $file"
        done <<< "$LOGS"
        echo -e "${GREEN}✓ Log cleanup complete${RESET}"
    fi
}

enable_docker_log_rotation() {
    if prompt "Enable Docker log rotation?"; then
        sudo bash -c 'cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}
EOF'
        sudo systemctl restart docker
        echo -e "${GREEN}✓ Docker log rotation enabled${RESET}"
    fi
}

############################################################
# FULL SAFE CLEANUP
############################################################

full_safe_cleanup() {
    docker_log_cleanup
    clean_journal_logs
    clean_apt_cache
    clean_old_kernels
    clean_snap_cache
    docker_prune_safe
    echo -e "${GREEN}✓ Full cleanup complete${RESET}"
}

############################################################
# MENU SYSTEM
############################################################

while true; do
clear
echo -e "${CYAN}"
echo "===================================="
echo "      VM SYSTEM HEALTH MANAGER"
echo "===================================="
echo -e "${RESET}"

echo "1) Quick health check"
echo "2) Full diagnostics"
echo "3) Clean Docker logs (safe)"
echo "4) Prune Docker images/volumes (safe)"
echo "5) Clean journal logs"
echo "6) Clean apt cache & old kernels"
echo "7) Full safe cleanup"
echo "8) Show top 10 disk-consuming paths"
echo "9) Enable Docker log rotation"
echo "0) Exit"
echo

read -p "Select an option: " opt

case $opt in
    1) health_check; pause ;;
    2) full_diagnostics; pause ;;
    3) docker_log_cleanup; pause ;;
    4) docker_prune_safe; pause ;;
    5) clean_journal_logs; pause ;;
    6) clean_apt_cache; clean_old_kernels; pause ;;
    7) full_safe_cleanup; pause ;;
    8) du -xh / | sort -h | tail -n 10; pause ;;
    9) enable_docker_log_rotation; pause ;;
    0) exit 0 ;;
    *) echo "Invalid choice"; pause ;;
esac
done