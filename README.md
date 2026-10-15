# FFXI · Cheeseplate

Personal Final Fantasy XI and Windower settings, plus the Cheeseplate (Asura) progress board. This is a snapshot of config files, not the game or Windower install.

PlayOnline login files, cookies, and mail are not included.

## Progress board

Job, mission, and currency tracker:

https://freechie.github.io/ffxi-cheeseplate/

Source lives in `docs/` (GitHub Pages).

## Layout

- `docs/` - progress board for GitHub Pages
- `windower/settings.xml` - launcher profile (UI scale, autoload list)
- `windower/scripts/` - `init.txt` and autoload
- `windower/plugins/settings/` - plugin configs
- `windower/plugins/ll/` - LightLuggage lists
- `windower/addons/*/data/` - addon settings, filters, and GearSwap
- `game/USER/` - in-game macros, equipment sets, and client options
- `windower/keybinds.md` - THF / DNC / NIN number-row keybinds (set by GearSwap)
- `game/settings.xml` - retail client profile
- `dgvoodoo/dgVoodoo.conf` - DirectX 8 wrapper used by PlayOnline

XIPivot overlay settings are here. The `remapster` DAT files themselves stay in the Windower install.

## Restore

Copy each tree back over the matching folder:

- `windower/` → `C:\Windower4\`
- `game/USER/` → `FINAL FANTASY XI\USER\`
- `game/settings.xml` → `FINAL FANTASY XI\settings.xml`
- `dgvoodoo/dgVoodoo.conf` → `PlayOnlineViewer\dgVoodoo.conf`

Close PlayOnline before restoring `game/USER`.
