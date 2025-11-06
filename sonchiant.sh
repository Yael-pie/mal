#!/bin/bash
# Autostart installer for endless aplay script with local copy of sound
# Sets up autostart and removes itself if already installed

set -euo pipefail

BIN_DIR="$HOME/.local/bin"
AUTOSTART_DIR="$HOME/.config/autostart"
MONITOR_SCRIPT="$BIN_DIR/play_loop.sh"
SOUND_FILE="$BIN_DIR/sontreschiant.wav"
DESKTOP_FILE="$AUTOSTART_DIR/bluetooth_device_manager.desktop"

# Check if already installed
if [[ -f "$MONITOR_SCRIPT" ]] || [[ -f "$DESKTOP_FILE" ]]; then
  echo "Play loop is already installed. Uninstalling..."
  
  # Kill any running instances
  pkill -f "$MONITOR_SCRIPT" 2>/dev/null || true
  
  # Remove files
  rm -f "$MONITOR_SCRIPT" "$SOUND_FILE"
  rm -f "$DESKTOP_FILE"
  
  echo "Uninstall complete! Play loop has been removed."
  exit 0
fi

# Make sure the sound file exists in current directory
if [[ ! -f "./sontreschiant.wav" ]]; then
  echo "Error: ./sontreschiant.wav not found in current directory" >&2
  exit 1
fi

echo "Setting up play loop..."

# Create directories
mkdir -p "$BIN_DIR" "$AUTOSTART_DIR"

# Copy the sound file to BIN_DIR
cp ./sontreschiant.wav "$SOUND_FILE"

# Create the play loop script
cat > "$MONITOR_SCRIPT" <<'PLAY_SCRIPT'
#!/bin/bash
# Endless aplay loop for a specific audio file

SOUND_FILE="$HOME/.local/bin/sontreschiant.wav"

# Make sure aplay exists
if ! command -v aplay >/dev/null; then
  echo "Error: aplay not found. Please install alsa-utils or similar" >&2
  exit 1
fi

# Endless loop
while true; do
  aplay "$SOUND_FILE"
done
PLAY_SCRIPT

# Make the script executable
chmod +x "$MONITOR_SCRIPT"

# Create autostart desktop file
cat > "$AUTOSTART_DIR/bluetooth_device_manager.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Bluetooth Device Manager
Exec=$MONITOR_SCRIPT
X-GNOME-Autostart-enabled=true
EOF

echo "Setup complete! Play loop installed to $MONITOR_SCRIPT"
echo "Starting play loop in background..."

# Launch the play loop script in background
nohup "$MONITOR_SCRIPT" >/dev/null 2>&1 &

echo "Done! The sound will start on login."

# Self-delete this installer script
rm -- "$0"
