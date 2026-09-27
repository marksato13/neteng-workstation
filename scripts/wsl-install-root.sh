#!/usr/bin/env bash
# Se ejecuta como root via: wsl -d Ubuntu -u root -- bash <este fichero>
set -e
export DEBIAN_FRONTEND=noninteractive

echo "== apt update =="
apt-get update -qq

echo "== instalando =="
apt-get install -y -qq --no-install-recommends \
    nmap tcpdump dnsutils snmp snmp-mibs-downloader iperf3 mtr-tiny jq

echo
echo "== verificacion =="
for t in nmap tcpdump dig snmpwalk iperf3 mtr jq; do
    if command -v "$t" >/dev/null 2>&1; then
        printf '  OK     %-10s %s\n' "$t" "$(command -v "$t")"
    else
        printf '  FALTA  %s\n' "$t"
    fi
done
