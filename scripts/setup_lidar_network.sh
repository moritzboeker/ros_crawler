#!/usr/bin/env bash
# One-time network setup for the Vanjee WLR-719C lidar.
#
# Creates a persistent NetworkManager profile that puts the host on the
# lidar's ethernet link:
#   host  192.168.0.64/32 on the given interface
#   lidar 192.168.0.2 reachable via a scoped host route
# The /32 address plus the host route leave a wifi LAN that also uses
# 192.168.0.x untouched. Keep the addresses in sync with
# bringup/config/vanjee_wlr719c_cfg.yaml.
#
# Usage: sudo ./scripts/setup_lidar_network.sh [interface]
#        (default interface: eth0)

set -euo pipefail

IFACE="${1:-eth0}"
HOST_ADDR="192.168.0.64/32"  # host_address in vanjee_wlr719c_cfg.yaml
LIDAR_ADDR="192.168.0.2/32"  # lidar_address in vanjee_wlr719c_cfg.yaml
CON_NAME="lidar"

if [[ $EUID -ne 0 ]]; then
    echo "Please run with sudo: sudo $0 [interface]" >&2
    exit 1
fi

if ! command -v nmcli >/dev/null 2>&1; then
    echo "nmcli not found - this script requires NetworkManager." >&2
    exit 1
fi

if ! nmcli -t -f DEVICE device status | grep -qx "$IFACE"; then
    echo "Interface '$IFACE' not found. Available devices:" >&2
    nmcli device status >&2
    echo "Pass the ethernet interface as argument, e.g.: sudo $0 enp0s31f6" >&2
    exit 1
fi

# Idempotent: replace any previous profile of the same name.
nmcli connection delete "$CON_NAME" >/dev/null 2>&1 || true

nmcli connection add \
    type ethernet \
    ifname "$IFACE" \
    con-name "$CON_NAME" \
    connection.autoconnect yes \
    connection.autoconnect-priority 100 \
    ipv4.method manual \
    ipv4.addresses "$HOST_ADDR" \
    ipv4.routes "$LIDAR_ADDR" \
    ipv6.method disabled

nmcli connection up "$CON_NAME"

echo "NetworkManager profile '$CON_NAME' active on $IFACE."
if ping -c 3 -W 2 "${LIDAR_ADDR%/32}" >/dev/null 2>&1; then
    echo "Lidar at ${LIDAR_ADDR%/32} is reachable."
else
    echo "Lidar at ${LIDAR_ADDR%/32} not reachable (is it connected and powered?)."
fi
