#!/bin/bash
set -euo pipefail

# ========== Color Codes ==========
NONE='\033[0m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

# ========== Helper Functions ==========
section() { echo -e "\n${PURPLE}========== $1 ==========${NONE}\n"; }
info()    { echo -e "${CYAN}ℹ️  $1${NONE}"; }
success() { echo -e "${GREEN}✅ $1${NONE}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NONE}"; }
error()   { echo -e "${RED}❌ $1${NONE}"; }

# ========== 1. Give execution permissions ==========
section "Setting execution permissions for provisioning scripts"
if find ./provision -type f -iname "*.sh" -exec chmod +x {} \;; then
  success "All shell scripts under ./provision are now executable."
else
  error "Failed to set execution permissions."
  exit 1
fi

# ========== 2. Set Hostname ==========
section "Setting system hostname"
if sh ./provision/shell/set_hostname.sh; then
  success "Hostname configuration complete."
else
  error "Hostname setup failed."
  exit 1
fi

# ========== 3. Install Ansible ==========
section "Installing Ansible"
if sh ./provision/shell/install_ansible.sh; then
  success "Ansible installation complete."
else
  error "Ansible installation failed."
  exit 1
fi

# ========== 4. Execute Ansible Playbook ==========
section "Running Ansible playbook"
if ansible-playbook provision/ansible/playbook.yml; then
  success "Ansible playbook executed successfully."
else
  error "Ansible playbook execution failed."
  exit 1
fi

## ========== 5. Configure Shell Profiles ==========
#section "Configuring shell profiles"
#cp -v .bash_profile ~/
#cp -v .zprofile ~/
#if source ~/.zprofile; then
#  success ".zprofile loaded successfully."
#else
#  warn "Couldn't source .zprofile automatically. Please open a new terminal."
#fi
#
## ========== Completion ==========
section "Provisioning Complete 🎉"
success "Your Linux Mint environment has been configured successfully!"
info "Next step: restart your terminal to finalize environment variables."
