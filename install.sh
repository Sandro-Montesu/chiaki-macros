#!/usr/bin/env bash
set -euo pipefail

# chiaki-macro installer — idempotent, works on Debian/Raspberry Pi OS/Ubuntu
# Run:  ./install.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
SCRIPT_SRC="$SCRIPT_DIR/chiaki-macro"
SCRIPT_DST="$BIN_DIR/chiaki-macro"

echo "=== chiaki-macro installer ==="
echo

# ── 1. System dependencies ──────────────────────────────────────────
echo "[1/5] Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq python3-evdev

# ── 2. uinput permissions (idempotent) ──────────────────────────────
echo "[2/5] Setting up /dev/uinput permissions..."
UDEV_RULE='/etc/udev/rules.d/99-uinput.rules'
UDEV_CONTENT='KERNEL=="uinput", MODE="0660", GROUP="input"'

if ! grep -qxF "$UDEV_CONTENT" "$UDEV_RULE" 2>/dev/null; then
    echo "$UDEV_CONTENT" | sudo tee "$UDEV_RULE" > /dev/null
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    echo "  udev rule installed."
else
    echo "  udev rule already present."
fi

if ! groups "$USER" | grep -qw input; then
    sudo usermod -a -G input "$USER"
    echo "  Added $USER to 'input' group — log out and back in for this to take effect."
    echo "  (or run: newgrp input)"
else
    echo "  User already in 'input' group."
fi

# ── 3. Ensure ~/.local/bin exists ───────────────────────────────────
echo "[3/5] Creating $BIN_DIR..."
mkdir -p "$BIN_DIR"

# ── 4. Symlink script ───────────────────────────────────────────────
echo "[4/5] Linking chiaki-macro..."
if [ -L "$SCRIPT_DST" ] || [ -f "$SCRIPT_DST" ]; then
    if [ "$(readlink -f "$SCRIPT_DST" 2>/dev/null)" = "$SCRIPT_SRC" ]; then
        echo "  Symlink already correct."
    else
        rm -f "$SCRIPT_DST"
        ln -s "$SCRIPT_SRC" "$SCRIPT_DST"
        echo "  Symlink updated."
    fi
else
    ln -s "$SCRIPT_SRC" "$SCRIPT_DST"
    echo "  Symlink created."
fi

# ── 5. Add ~/.local/bin to PATH if missing ──────────────────────────
echo "[5/5] Ensuring ~/.local/bin is in PATH..."
PROFILE="$HOME/.profile"
if [ -f "$PROFILE" ]; then
    if grep -q ".local/bin" "$PROFILE"; then
        echo "  Already in .profile."
    else
        echo '' >> "$PROFILE"
        echo '# added by chiaki-macro installer' >> "$PROFILE"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$PROFILE"
        echo "  Added to .profile — restart your shell or run:  source ~/.profile"
    fi
else
    echo 'export PATH="$HOME/.local/bin:$PATH"' > "$PROFILE"
    echo "  Created .profile with PATH."
fi

echo
echo "=== Done ==="
echo
echo "chiaki-macro is ready to use:"
echo "  chiaki-macro devices"
echo "  chiaki-macro record my_macro"
echo "  chiaki-macro play my_macro"
echo
if ! groups "$USER" | grep -qw input; then
    echo "NOTE: log out and back in for uinput group to take effect."
fi
