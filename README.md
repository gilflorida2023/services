# User Systemd Services

Systemd user services for personal automation on Debian Linux.

## Services

### numlock-off.service
Forces NumLock off every 15 seconds on display `:0` using `numlockx`. Runs after graphical session starts and restarts on failure.

**Requirements:** `numlockx` package (`sudo apt install numlockx`)

### ollama-tunnel.service
Creates an SSH tunnel to an Ollama server at `m4@192.168.0.7:11434`, forwarding local port 11434 to the remote Ollama port. Uses SSH key at `~/.ssh/id_rsa` with keepalive settings.

**Requirements:**
- SSH key at `~/.ssh/id_rsa` with access to `m4@192.168.0.7`
- SSH server running on `m4@192.168.0.7` with Ollama listening on port 11434

## Installation

### Quick Install
```bash
./install-services.sh
```

### Manual Install
```bash
# Create user systemd directory
mkdir -p ~/.config/systemd/user

# Copy service files
cp *.service ~/.config/systemd/user/

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable and start services
systemctl --user enable --now numlock-off.service
systemctl --user enable --now ollama-tunnel.service
```

### Requirements (Debian/Ubuntu)
```bash
sudo apt update && sudo apt install numlockx openssh-client
```

### SSH Key Setup (for ollama-tunnel)
```bash
# Generate key if needed
ssh-keygen -t ed25519 -f ~/.ssh/id_rsa

# Copy to remote server
ssh-copy-id m4@192.168.0.7
```

### Enable User Lingering (for services to start at boot)
```bash
sudo loginctl enable-linger $USER
```

## Service Management

```bash
# Status
systemctl --user status numlock-off.service
systemctl --user status ollama-tunnel.service

# Logs
journalctl --user -u numlock-off.service -f
journalctl --user -u ollama-tunnel.service -f

# Restart
systemctl --user restart numlock-off.service
systemctl --user restart ollama-tunnel.service

# Stop/Disable
systemctl --user disable --now numlock-off.service
systemctl --user disable --now ollama-tunnel.service
```

## Service Details

### numlock-off.service
- **Type:** simple
- **Restart:** always (10s delay, max 3 restarts/60s)
- **Runs after:** graphical-session.target
- **Command:** `while true; do DISPLAY=:0 numlockx off; sleep 15; done`
- **Stop:** kills `numlockx` processes

### ollama-tunnel.service
- **Type:** simple
- **Restart:** always (10s delay, max 3 restarts/60s)
- **Runs after:** network-online.target
- **SSH Options:** Keepalive 15s, max 3 failures, exit on forward failure
- **Stop:** kills the specific SSH tunnel process
