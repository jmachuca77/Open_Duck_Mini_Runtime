#!/bin/bash

# install-components.sh
# This script should be run with: sudo ./install-components.sh

# Exit on failure
set -e

# --- Color codes ---
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Functions for printing messages ---
info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Check if run as root ---
if [ "$EUID" -ne 0 ]; then
  error "Please run this script with sudo:"
  echo "  sudo ./install-components.sh"
  exit 1
fi

info "Updating system..."
apt update && apt upgrade -y

info "Installing required packages..."
apt install -y git python3-pip python3-virtualenvwrapper python3-picamzero

# .bashrc modifications
BASHRC_PATH="/home/$SUDO_USER/.bashrc"
VENV_CONFIG='
# Virtualenvwrapper settings
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
'

info "Updating .bashrc..."
if ! grep -q "virtualenvwrapper" "$BASHRC_PATH"; then
  echo "$VENV_CONFIG" >> "$BASHRC_PATH"
  success "Added virtualenvwrapper configuration to .bashrc"
else
  warn "Virtualenvwrapper configuration already present in .bashrc"
fi

if ! grep -q "workon open-duck-mini-runtime" "$BASHRC_PATH"; then
  echo "workon open-duck-mini-runtime" >> "$BASHRC_PATH"
  success "Added 'workon open-duck-mini-runtime' to .bashrc"
else
  warn "'workon open-duck-mini-runtime' already present in .bashrc"
fi

info "Enabling I2C..."
raspi-config nonint do_i2c 0

info "Setting I2C speed to 400kHz..."
if ! grep -q "dtparam=i2c_arm_baudrate=400000" /boot/config.txt; then
  echo "dtparam=i2c_arm_baudrate=400000" >> /boot/config.txt
  success "I2C baudrate set to 400kHz"
else
  warn "I2C baudrate already set"
fi

info "Creating udev rule for USB serial latency timer..."
UDEV_RULE='SUBSYSTEM=="usb-serial", DRIVER=="ftdi_sio", ATTR{latency_timer}="1"'
RULE_FILE="/etc/udev/rules.d/99-usb-serial.rules"

if [ ! -f "$RULE_FILE" ]; then
  echo "$UDEV_RULE" > "$RULE_FILE"
  success "Created $RULE_FILE"
else
  if ! grep -q "$UDEV_RULE" "$RULE_FILE"; then
    echo "$UDEV_RULE" >> "$RULE_FILE"
    success "Appended rule to $RULE_FILE"
  else
    warn "USB serial latency timer rule already exists"
  fi
fi

info "Setting up Python virtual environment and installing Open Duck Mini Runtime..."

sudo -u "$SUDO_USER" bash << 'EOF'
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh

# Create virtualenv if it doesn't exist
if [ ! -d "$WORKON_HOME/open-duck-mini-runtime" ]; then
  echo "[INFO] Creating virtualenv 'open-duck-mini-runtime'..."
  mkvirtualenv -p python3 open-duck-mini-runtime
else
  echo "[INFO] Virtual environment 'open-duck-mini-runtime' already exists. Skipping creation."
fi

workon open-duck-mini-runtime

# Clone or update the repo
cd $HOME
if [ ! -d "Open_Duck_Mini_Runtime" ]; then
  echo "[INFO] Cloning Open_Duck_Mini_Runtime..."
  git clone https://github.com/apirrone/Open_Duck_Mini_Runtime
  cd Open_Duck_Mini_Runtime
  git checkout v2
else
  echo "[INFO] Repo already cloned. Fetching latest..."
  cd Open_Duck_Mini_Runtime
  git fetch
  git checkout v2
fi

# Only install if not already installed
PKG_NAME="mini-bdx-runtime"
if ! pip show "$PKG_NAME" > /dev/null 2>&1; then
  echo "[INFO] Installing Open Duck Mini Runtime..."
  pip install -e .
  pip install lgpio
else
  echo "[INFO] '$PKG_NAME' already installed in the virtualenv. Skipping pip install."
fi
EOF

info "Creating .inputrc for command history search..."
INPUTRC_PATH="/home/$SUDO_USER/.inputrc"
HISTORY_KEYS='"\e[A": history-search-backward
"\e[B": history-search-forward'

echo "$HISTORY_KEYS" > "$INPUTRC_PATH"
chown "$SUDO_USER:$SUDO_USER" "$INPUTRC_PATH"
success "Added history search keybindings to .inputrc"

success "Setup complete! You may now reboot your Raspberry Pi if needed."
