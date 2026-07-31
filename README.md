# proton-install

Run a Windows game installer in a throwaway Steam Proton prefix. Useful for DRM-free installers (GOG, old discs) that you want on disk before adding them to Steam as a non-Steam game.

## Requirements

- Steam, with at least one Proton runner installed
- `bash`

## Install

```sh
curl -O https://raw.githubusercontent.com/HydroshieldMKII/proton-install/main/install-game.sh
chmod +x install-game.sh
```

Edit the variables at the top before the first run, see [Configuration](#configuration).

## Find available Proton versions

Run this to list the Proton runners already installed:

```sh
STEAM_ROOT="$HOME/.local/share/Steam"
for d in "$STEAM_ROOT"/steamapps/common/*/ "$STEAM_ROOT"/compatibilitytools.d/*/; do
    [ -x "$d/proton" ] && basename "$d"
done | sort
```

```
GE-Proton11-1
Proton 11.0
Proton - Experimental
```

Use the printed name as `PROTON_VERSION`. To get another version, install [Valve's Proton](https://github.com/ValveSoftware/Proton)
from your Steam library with the type filter set to Tools, or unpack a third-party build like
[GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom/releases) into `compatibilitytools.d/`.

## Usage

```sh
./install-game.sh ~/Downloads/MyGame/setup.exe
./install-game.sh --killall  # kill all installers and cleanup
```

The script prints an install path and waits for confirmation:

```
Game name:    MyGame
Install into: Z:\Games\MyGame   <- Choose this path in your installer
```

## Configuration

Edit the variables at the top of the script:

| Variable | Default | Notes |
| --- | --- | --- |
| `STEAM_ROOT` | `$HOME/.local/share/Steam` | Steam's data directory. Flatpak Steam uses `~/.var/app/com.valvesoftware.Steam/.local/share/Steam`. |
| `PROTON_VERSION` | `Proton 11.0` | A runner name from the command above. Must match the directory name exactly, spaces included. |
| `GAMES_DIR` | `$HOME/Games` | Where installed games land. Must be inside `$HOME`. |
| `WINE_DPI` | `96` | Installer window scaling. Common values are listed in the script. |
| `CACHE_DIR` | `$HOME/.cache/proton-installers` | Holds the throwaway prefixes. Cleared when the script exits, or by `--killall` if anything survives. |
