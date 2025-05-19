#!/bin/bash
set -eo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root. Exiting."
    exit 1
fi

echo "Running as root. Proceeding with the script..."

# check connectivity
echo "[!] Checking that the box is reachable"
/usr/bin/ping -c 1 $1

# TODO: check that the machine actually advertises the $2 VHOST, smth like:
# curl -s http://10.10.11.67 --head|grep -i location|cut -d' ' -f2|cut -d'/' -f3

# add static DNS to /etc/hosts
if grep -qi $2 /etc/hosts; then
    echo "[!] $2 already exists in /etc/hosts"
else
    echo "[+] adding $2 to /etc/hosts"
    echo -e "$1\t$2" >> /etc/hosts
    /usr/bin/ping -c 1 $2
fi

# 1. start nmap scan
/usr/bin/mkdir -p nmap/ 2>/dev/null
/usr/bin/chown -R kali:kali nmap/

echo -e "[+] Starting nmap scan...\n"
/usr/bin/nmap -sV -sC -oN nmap/$2.nmap $2

echo -e "\n[+] Finished without any errors."

# 2. start VHOST scan