#!/bin/bash

# ==== CONFIGURABLE PARAMETERS ====
WG_DIR="/etc/wireguard"
WG_INTERFACE="wg0"
CLIENT_NAME="$1"
SERVER_PUBLIC_IP="YOUR.SERVER.IP.HERE"
SERVER_PORT=51820
CLIENT_BASE_IP="10.0.0." 
CLIENT_DNS="1.1.1.1"
WG_CONFIG="$WG_DIR/$WG_INTERFACE.conf"
CLIENTS_DIR="$WG_DIR/clients"
# =================================

if [ -z "$CLIENT_NAME" ]; then
  echo "[ERR] Client name not provided"
  echo "Usage: $0 <client-name>"
  exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "[ERR] Please run as root"
  exit 1
fi

# Generate client keys
CLIENT_PRIV_KEY=$(wg genkey)
CLIENT_PUB_KEY=$(echo "$CLIENT_PRIV_KEY" | wg pubkey)

# Find next available IP
USED_IPS=$(grep AllowedIPs "$WG_CONFIG" | awk -F '[ ./]' '{print $4}')
NEXT_IP=2
while echo "$USED_IPS" | grep -q "^$NEXT_IP$"; do
  NEXT_IP=$NEXT_IP+1
  echo "[INFO] Checking IP $NEXT_IP"
done
CLIENT_IP="${CLIENT_BASE_IP}${NEXT_IP}"

# Generate client config
mkdir -p "$CLIENTS_DIR"
CLIENT_CONFIG="$CLIENTS_DIR/${CLIENT_NAME}.conf"

cat > "$CLIENT_CONFIG" <<EOF
[Interface]
PrivateKey = $CLIENT_PRIV_KEY
Address = $CLIENT_IP/32
DNS = $CLIENT_DNS

[Peer]
PublicKey = $(wg show "$WG_INTERFACE" public-key)
Endpoint = $SERVER_PUBLIC_IP:$SERVER_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Add to server config
cat >> "$WG_CONFIG" <<EOF

# ${CLIENT_NAME}
[Peer]
PublicKey = $CLIENT_PUB_KEY
AllowedIPs = $CLIENT_IP/32
EOF

# Apply changes
wg set $WG_INTERFACE peer $CLIENT_PUB_KEY allowed-ips $CLIENT_IP/32


# Done
qrencode -t ansiutf8 < $CLIENT_CONFIG
echo ""
echo "Client '${CLIENT_NAME}' added!"
echo "Config saved at: $CLIENT_CONFIG"
echo "Assigned IP: $CLIENT_IP"
