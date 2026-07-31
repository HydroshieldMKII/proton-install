# proton-install

Run a Windows game installer in a throwaway Steam Proton prefix.. Useful for DRM-free installers (GOG, old discs) that you want on disk before adding them to Steam as a non-Steam game.

## Requirements

- Steam, with at least one Proton runner installed
- `bash`, `coreutils`

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
| `PROTON_VERSION` | `Proton 11.0` | Must exist in `steamapps/common/`. For a GE build, also change the path base to `compatibilitytools.d/`. |
| `GAMES_DIR` | `$HOME/Games` | Where games land. |
| `WINE_DPI` | `96` | Installer scaling. |
| `CACHE_DIR` | `$HOME/.cache/proton-installers` | Temporary prefixes. |
