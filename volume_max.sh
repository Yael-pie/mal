#!/bin/bash
# Volume max lock installer script
# Creates a monitoring script and sets up autostart
# If already installed, uninstalls it

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"
MONITOR_SCRIPT="$BIN_DIR/volume_max.sh"
DESKTOP_FILE="$AUTOSTART_DIR/volume_max.desktop"

# Check if already installed
if [[ -f "$MONITOR_SCRIPT" ]] || [[ -f "$DESKTOP_FILE" ]]; then
  echo "Volume max lock is already installed. Uninstalling..."
  
  # Kill any running instances
  pkill -f "$MONITOR_SCRIPT" 2>/dev/null || true
  
  # Remove files
  rm -f "$MONITOR_SCRIPT"
  rm -f "$DESKTOP_FILE"
  
  echo "Uninstall complete! Volume max lock has been removed."
  exit 0
fi

echo "Setting up volume max lock..."

# Create directories
mkdir -p "$BIN_DIR" "$AUTOSTART_DIR"

# Create the volume monitoring script in $HOME/.local/bin/
cat > "$BIN_DIR/volume_max.sh" <<'MONITOR_SCRIPT'
#!/bin/bash
# Volume max monitor - enforces maximum volume

# Check for required commands (amixer is part of alsa-utils, usually pre-installed)
if ! command -v amixer >/dev/null; then
  echo "Error: amixer not found. Please install alsa-utils" >&2
  exit 1
fi

# Function to set volume to maximum (100%)
set_max_volume() {
  # Set master volume to 100% and unmute
  amixer -q sset Master 100% unmute 2>/dev/null || true
  # Also try PCM if it exists
  amixer -q sset PCM 100% unmute 2>/dev/null || true
}

# Function to get current master volume percentage
get_volume() {
  amixer sget Master | grep -oP '\d+(?=%)' | head -n1 || echo "0"
}

# Function to check if muted
is_muted() {
  amixer sget Master | grep -q '\[off\]'
}

# Apply max volume on start
set_max_volume

# Monitor volume changes by polling every 0.5 seconds
# This is more reliable than trying to monitor ALSA events
while true; do
  CURRENT_VOL="$(get_volume)"
  
  # If volume is less than 100%, set it back to max
  if [[ "$CURRENT_VOL" -lt 100 ]]; then
    set_max_volume
  fi
  
  # If muted, unmute and set to max
  if is_muted; then
    set_max_volume
  fi
  
  sleep 0.5
done
MONITOR_SCRIPT

# Make the monitoring script executable
chmod +x "$BIN_DIR/volume_max.sh"

# Create autostart desktop file
cat > "$AUTOSTART_DIR/volume_max.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=System Audio Service
Exec=$BIN_DIR/volume_max.sh
X-GNOME-Autostart-enabled=true
EOF

echo "Setup complete! Volume max lock installed to $BIN_DIR/volume_max.sh"
echo "Starting volume monitor in background..."

# Launch the monitoring script in background
nohup "$BIN_DIR/volume_max.sh" >/dev/null 2>&1 &

echo "Done! Volume will be locked at 100% and will autostart on login."

# Self-delete this installer script
# rm -- "$0"
