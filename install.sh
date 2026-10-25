#!/usr/bin/env bash
# ==============================================================================
# omega-desktop installer — idempotent.
#
# Symlinks the tracked configs into $HOME and the scripts into ~/.local/bin.
# Anything it would overwrite is first copied aside as <file>.bak (it never
# clobbers your data). Safe to re-run; re-running just refreshes the symlinks.
# ==============================================================================

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APPS_DIR="$HOME/.local/share/applications"
AUTOSTART_DIR="$HOME/.config/autostart"

info()  { printf '\033[1;34m[omega]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[omega]\033[0m %s\n' "$1"; }

backup_if_real() {
    # back up a path only if it exists and is NOT already our symlink
    local p="$1"
    if [ -e "$p" ] && [ ! -L "$p" ]; then
        local bak="$p.bak"
        [ -e "$bak" ] && bak="$p.bak.$(date +%s)"
        cp -a "$p" "$bak"
        warn "backed up existing $p -> $bak"
    fi
}

link() {
    # link <source> <dest>
    local src="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    backup_if_real "$dest"
    ln -sfn "$src" "$dest"
}

info "Installing from $REPO"

# --- configs (mirror the config/ tree into $HOME) ---------------------------
if [ -d "$REPO/config" ]; then
    while IFS= read -r -d '' f; do
        rel="${f#"$REPO"/config/}"
        link "$f" "$HOME/$rel"
    done < <(find "$REPO/config" -type f -print0)
    info "Linked configs."
fi

# --- scripts into ~/.local/bin ----------------------------------------------
mkdir -p "$BIN_DIR"
for f in "$REPO"/bin/*; do
    [ -f "$f" ] || continue
    name="$(basename "$f")"
    case "$name" in *.py) continue ;; esac   # library, not a command
    chmod +x "$f" 2>/dev/null || true
    link "$f" "$BIN_DIR/$name"
done
info "Linked scripts into $BIN_DIR."

# --- desktop launchers ------------------------------------------------------
if [ -f "$REPO/config/omega-guide.desktop" ]; then
    mkdir -p "$APPS_DIR" "$AUTOSTART_DIR"
    link "$REPO/config/omega-guide.desktop" "$APPS_DIR/omega-guide.desktop"
    link "$REPO/config/omega-guide.desktop" "$AUTOSTART_DIR/omega-guide.desktop"
    info "Installed omega-guide launcher + autostart."
fi

# --- this repo's own pre-commit hook ----------------------------------------
if [ -d "$REPO/.git" ] && [ -f "$REPO/bin/git-security-hook.sh" ]; then
    ln -sfn "$REPO/bin/git-security-hook.sh" "$REPO/.git/hooks/pre-commit"
    chmod +x "$REPO/bin/git-security-hook.sh"
    info "Installed security pre-commit hook."
fi

# --- optional: systemd --user daily snapshot timer --------------------------
if command -v systemctl >/dev/null 2>&1 && [ -d "$REPO/config/systemd" ]; then
    UNIT_DIR="$HOME/.config/systemd/user"
    mkdir -p "$UNIT_DIR"
    cp -f "$REPO/config/systemd/omega-snapshot.service" "$UNIT_DIR/"
    cp -f "$REPO/config/systemd/omega-snapshot.timer" "$UNIT_DIR/"
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now omega-snapshot.timer 2>/dev/null \
        && info "Enabled daily omega-snapshot.timer." \
        || warn "Could not enable omega-snapshot.timer (no user session?)."
fi

info "Done. Open the guide with:  omega-guide"
