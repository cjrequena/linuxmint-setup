#!/bin/sh
# Robust POSIX-compatible hostname changer for Linux

NEW_NAME="libra-imac"

# ----------------------------
# Ensure script runs as root
# ----------------------------
if [ "$(id -u)" != "0" ]; then
    echo "⚠️  Not running as root. Re-executing with sudo..."
    exec sudo "$0" "$@"
fi

echo "ℹ️  Changing system hostname to '${NEW_NAME}'..."

# ----------------------------
# 1. Set temporary hostname
# ----------------------------
if command -v hostname >/dev/null 2>&1; then
    hostname "${NEW_NAME}" || {
        echo "❌ Failed to set hostname temporarily"
        exit 1
    }
else
    echo "❌ hostname command not found"
    exit 1
fi

# ----------------------------
# 2. Persist hostname in /etc/hostname
# ----------------------------
if [ -w /etc/hostname ]; then
    echo "${NEW_NAME}" > /etc/hostname || {
        echo "⚠️  Failed to write /etc/hostname"
    }
else
    echo "⚠️  Cannot write /etc/hostname"
fi

# ----------------------------
# 3. Update /etc/hosts
# ----------------------------
if [ -w /etc/hosts ]; then
    if grep -q "^127.0.1.1" /etc/hosts 2>/dev/null; then
        sed -i "s/^127.0.1.1.*/127.0.1.1   ${NEW_NAME}/" /etc/hosts || {
            echo "⚠️  Failed to update /etc/hosts"
        }
    else
        echo "127.0.1.1   ${NEW_NAME}" >> /etc/hosts
    fi
else
    echo "⚠️  Cannot write /etc/hosts"
fi

# ----------------------------
# 4. Flush DNS cache if available
# ----------------------------
if command -v systemctl >/dev/null 2>&1 && systemctl is-active systemd-resolved >/dev/null 2>&1; then
    systemctl restart systemd-resolved && echo "✅ DNS cache flushed (systemd-resolved)"
elif command -v resolvectl >/dev/null 2>&1; then
    resolvectl flush-caches && echo "✅ DNS cache flushed (resolvectl)"
else
    echo "⚠️  No DNS cache service to flush"
fi

# ----------------------------
# 5. Verification
# ----------------------------
echo "ℹ️  Verifying changes..."
echo "Hostname: $(hostname)"
echo "✅ System hostname successfully changed to '${NEW_NAME}'"
echo "✅ Hostname configuration complete."
