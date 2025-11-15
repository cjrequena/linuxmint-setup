#!/bin/sh
# Simple Ansible installer for Linux Mint / Ubuntu

# Auto-sudo if not root
if [ "$(id -u)" != "0" ]; then
    exec sudo "$0" "$@"
fi

# Update package lists
apt-get update -y

# Install Ansible
apt-get install -y ansible

# Verify installation
if command -v ansible >/dev/null 2>&1; then
    echo "✅ Ansible installed successfully."
else
    echo "❌ Ansible installation failed."
    exit 1
fi
