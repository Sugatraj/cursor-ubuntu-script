#!/bin/bash
set -euo pipefail

# === Config ===
APPDIR="$HOME/Applications"
SYMLINK_PATH="$APPDIR/cursor.AppImage"
ICON_PATH="$HOME/.local/share/icons/cursor-icon.svg"
DESKTOP_FILE_PATH="$HOME/.local/share/applications/cursor.desktop"
CURSOR_URL="https://downloader.cursor.sh/linux/appImage"

# === Ensure directories exist ===
mkdir -p "$APPDIR" "$(dirname "$ICON_PATH")" "$(dirname "$DESKTOP_FILE_PATH")"

echo "🔍 Checking for latest Cursor release..."
# Follow redirect to get actual latest filename
LATEST_URL=$(curl -sIL -o /dev/null -w '%{url_effective}' "$CURSOR_URL")
LATEST_FILE="$APPDIR/$(basename "$LATEST_URL")"

# === Check if already downloaded ===
if [ -f "$LATEST_FILE" ]; then
    echo "✅ Already have the latest Cursor: $(basename "$LATEST_FILE")"
else
    echo "⬇️ Downloading new version: $(basename "$LATEST_URL")"
    curl -L "$LATEST_URL" -o "$LATEST_FILE"
    chmod +x "$LATEST_FILE"
    echo "✅ Downloaded and marked executable."
fi

# === Update symlink ===
ln -sf "$LATEST_FILE" "$SYMLINK_PATH"
echo "🔗 Symlink updated to: $SYMLINK_PATH"

# === Ensure icon exists ===
if [ ! -f "$ICON_PATH" ]; then
    echo "⬇️ Downloading Cursor icon..."
    curl -L -o "$ICON_PATH" "https://www.cursor.so/brand/icon.svg"
    echo "✅ Icon saved to: $ICON_PATH"
fi

# === Ensure .desktop file ===
if [ ! -f "$DESKTOP_FILE_PATH" ] || ! grep -q "Exec=$SYMLINK_PATH" "$DESKTOP_FILE_PATH"; then
    cat > "$DESKTOP_FILE_PATH" <<EOF
[Desktop Entry]
Name=Cursor
Exec=$SYMLINK_PATH
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupWMClass=Cursor
X-AppImage-Version=latest
Comment=Cursor is an AI-first coding environment.
Categories=Utility;Development;
EOF
    chmod +x "$DESKTOP_FILE_PATH"
    echo "🖥️  .desktop file created/updated at: $DESKTOP_FILE_PATH"
else
    echo "✅ .desktop file already up-to-date."
fi

# === Print installed version ===
echo "ℹ️ Installed Cursor version info:"
"$SYMLINK_PATH" --version || true

echo "🎉 Cursor setup complete!"
