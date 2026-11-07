#!/usr/bin/env bash
#
# Run a Windows game installer in a throwaway Steam Proton prefix.
#
# Usage: install-game.sh <path/to/setup.exe>
#        install-game.sh --killall

set -euo pipefail

STEAM_ROOT="$HOME/.local/share/Steam"
PROTON_VERSION="Proton 11.0"
GAMES_DIR="$HOME/Games"
CACHE_DIR="$HOME/.cache/proton-installers"

# GNOME scale steps as DPI: 100%=96   125%=120  133%=128  166%=160
#                           200%=192  250%=240  266%=256
WINE_DPI="96"

die() { echo "Error: $*" >&2; exit 1; }

# Valve runners live in steamapps/common, third-party builds (GE-Proton, Tkg) in
# compatibilitytools.d. Use whichever one holds PROTON_VERSION.
PROTON_BASE=""
for base in "$STEAM_ROOT/steamapps/common" "$STEAM_ROOT/compatibilitytools.d"; do
    if [ -x "$base/$PROTON_VERSION/proton" ]; then PROTON_BASE="$base"; break; fi
done
PROTON="$PROTON_BASE/$PROTON_VERSION/proton"
WINESERVER="$PROTON_BASE/$PROTON_VERSION/files/bin/wineserver"

if [[ "${1:-}" == "--killall" ]]; then
    shopt -s nullglob
    for dir in "$CACHE_DIR"/pfx.*; do
        WINEPREFIX="$dir/pfx" "$WINESERVER" -k 2>/dev/null || true
    done
    # Wine children have Windows-style cmdlines, so match on the env var
    # rather than pgrep -f.
    for proc in /proc/[0-9]*; do
        pid="${proc#/proc/}"
        # get the env block, convert nulls to newlines, and check for 
        # the STEAM_COMPAT_DATA_PATH env var. If it matches kill
        tr '\0' '\n' < "$proc/environ" | grep -q "^STEAM_COMPAT_DATA_PATH=$CACHE_DIR/" &&
            kill -9 "$pid" 2>/dev/null
    done 2>/dev/null
    rm -rf "$CACHE_DIR"/pfx.*
    echo "Killed all installer processes, cleaned up $CACHE_DIR"
    exit 0
fi

[ $# -ge 1 ]     || { echo "Usage: $0 <path/to/setup.exe>" >&2; exit 1; }
[ -f "$1" ]      || die "file not found: $1"
[ -n "$PROTON_BASE" ] || die "Proton not found: $PROTON_VERSION"

SETUP_EXE="$(realpath "$1")"
GAME_NAME="$(basename "$(dirname "$SETUP_EXE")")"

echo "Game name:    $GAME_NAME"
echo "Install into: Z:\\Games\\$GAME_NAME   <- paste this into the installer"
read -rp "Proceed? [Y/n] " ok
[[ "${ok:-y}" =~ ^[Nn] ]] && exit 0

# Created up front: some installers reject a destination that does not exist.
#mkdir -p "$GAMES_DIR/$GAME_NAME" "$CACHE_DIR"

STEAM_COMPAT_DATA_PATH="$(mktemp -d "$CACHE_DIR/pfx.XXXXXX")"
STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_ROOT"
export STEAM_COMPAT_DATA_PATH STEAM_COMPAT_CLIENT_INSTALL_PATH
PFX="$STEAM_COMPAT_DATA_PATH/pfx"

trap 'WINEPREFIX="$PFX" "$WINESERVER" -k 2>/dev/null; rm -rf "$STEAM_COMPAT_DATA_PATH"' EXIT

"$PROTON" run wineboot.exe -w >/dev/null 2>&1 || true

if [ "$WINE_DPI" -ne 96 ]; then
    "$PROTON" run reg add "HKCU\\Control Panel\\Desktop" \
        /v LogPixels /t REG_DWORD /d "$WINE_DPI" /f >/dev/null 2>&1 || true
fi

# Point Z: at $HOME instead of Proton's default of /
ln -sfn "$HOME" "$PFX/dosdevices/z:"

"$PROTON" run "$SETUP_EXE"

echo "Install done"