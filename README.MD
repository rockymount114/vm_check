<p align="center">
  <img src="https://img.shields.io/badge/Shell-Script-89e051?logo=gnu-bash&logoColor=white" alt="Shell Scriptge/OS-Linux-blue?logo=linux
  <img src="https://img.shields.io/github/license/rockymount114/vm_check?color=brightgreen" alt="License Badge">io/github/repo-size/rockymount114/vm_check" alt="s://img.shields.io/github/last-commit/rockymount114/vm_check" alt="Last Commit Badge">

# **VM Check Utilities**

This repository contains two helpful Linux VM maintenance scripts designed to diagnose, monitor, and automatically fix common VM issues — especially for systems running **Docker**, **SQL Server**, **containers**, and **heavy logging workloads**.

## **Scripts Included**

### **1. `vm_health_check.sh`**
A lightweight, one‑shot script that performs:

- Memory usage report  
- Disk usage report (`/` and `/var`)  
- Docker storage size check  
- Detection of large Docker container logs  
- Automatic cleanup of oversized logs  
- Docker system usage overview  
- Docker log rotation check and guidance  

Use this script when you just want a quick health snapshot and immediate fixes for log bloat.

---

### **2. `vm_manager.sh`**
An advanced, interactive **menu‑based system maintenance tool**.  
Includes everything from `vm_health_check.sh` plus:

#### **Maintenance Tools**
- Clean apt cache (with confirmation)  
- Remove old kernels  
- Clear systemd journal logs  
- Remove snap cache  
- Safe prune for Docker images/containers/volumes  
- Truncate large Docker logs  

#### **Diagnostics & Reporting**
- Full memory, load, and disk reporting  
- Top 10 largest paths  
- Full VM diagnostics suite  

#### **Quality-of-Life Features**
- Default answers are **Yes when pressing Enter**  
- All actions require confirmation (safe mode)  
- Detect and enable Docker log rotation  

Use this script for ongoing maintenance, troubleshooting, and deep diagnostics.

---

## **Installation**

Clone the repository:

```bash
git clone https://github.com/rockymount114/vm_check.git
cd vm_check
```

Make both scripts executable:

```bash
chmod +x vm_health_check.sh
chmod +x vm_manager.sh
```

---

## **Usage**

### **Quick Health Check**
Run the lightweight one‑shot health script:

```bash
sudo ./vm_health_check.sh
```

---

### **Advanced Interactive Menu**
Run the full maintenance tool:

```bash
sudo ./vm_manager.sh
```

You will see a menu like:

```
1) Quick health check
2) Full diagnostics
3) Clean Docker logs (safe)
4) Prune Docker images/volumes (safe)
5) Clean journal logs
6) Clean apt cache & old kernels
7) Full safe cleanup
8) Show top 10 disk-consuming paths
9) Enable Docker log rotation
0) Exit
```

---

## **Recommended Use Cases**

- VMs running Docker that suffer from **json-log bloating**
- Proxmox VMs running low on disk space  
- Servers with limited boot disk sizes (48–64GB)  
- Systems running SQL Server, Supabase, or multiple containers  
- Routine monthly maintenance  
- Detecting resource usage issues  

---

## **Notes**

- All cleanup actions are **safe** and **ask for confirmation** by default.
- Pressing **Enter defaults to Yes**, making maintenance fast.
- No containers or services are stopped unless explicitly selected.
- Designed for Ubuntu/Debian-based systems, but works on most Linux systems with Docker installed.

---

## **License**

MIT License — free to use and modify.
