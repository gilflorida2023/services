#!/bin/bash
set -euo pipefail

SERVICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
SERVICES=("numlock-off.service" "ollama-tunnel.service")

echo "=== Installing user systemd services ==="
echo "Service directory: $SERVICE_DIR"
echo "Target directory: $USER_SYSTEMD_DIR"
echo

# Check dependencies
echo "Checking dependencies..."
if ! command -v numlockx &> /dev/null; then
    echo "WARNING: numlockx not installed. Install with: sudo apt install numlockx"
fi
if ! command -v ssh &> /dev/null; then
    echo "WARNING: ssh client not installed. Install with: sudo apt install openssh-client"
fi
if [[ ! -f "$HOME/.ssh/id_rsa" ]]; then
    echo "WARNING: SSH key not found at ~/.ssh/id_rsa (required for ollama-tunnel)"
    echo "Generate with: ssh-keygen -t ed25519 -f ~/.ssh/id_rsa"
    echo "Copy to server: ssh-copy-id m4@192.168.0.7"
fi
echo

# Create user systemd directory
mkdir -p "$USER_SYSTEMD_DIR"

# Copy service files
echo "Installing service files..."
for service in "${SERVICES[@]}"; do
    cp "$SERVICE_DIR/$service" "$USER_SYSTEMD_DIR/"
    echo "  Installed: $service"
done

# Reload systemd
echo "Reloading systemd user daemon..."
systemctl --user daemon-reload

# Enable and start services
echo "Enabling and starting services..."
for service in "${SERVICES[@]}"; do
    systemctl --user enable --now "$service"
    echo "  Started: $service"
done

# Enable lingering for boot persistence
echo
echo "Enabling user lingering (services start at boot)..."
sudo loginctl enable-linger "$USER" 2>/dev/null || echo "  (sudo failed, run manually: sudo loginctl enable-linger $USER)"

echo
echo "=== Installation complete ==="
echo
echo "Check status:"
echo "  systemctl --user status numlock-off.service"
echo "  systemctl --user status ollama-tunnel.service"
echo
echo "View logs:"
echo "  journalctl --user -u numlock-off.service -f"
echo "  journalctl --user -u ollama-tunnel.service -f"
echo
echo "Requirements:"
echo "  - numlockx: sudo apt install numlockx"
echo "  - SSH key at ~/.ssh/id_rsa with access to m4@192.168.0.7"
echo "  - For boot persistence: sudo loginctl enable-linger \$USER"
